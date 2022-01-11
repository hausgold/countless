# frozen_string_literal: true

module Countless
  # The source code statistics displaying handler.
  #
  # Heavily stolen from: https://bit.ly/3qpvgfu
  class SourceStatistics
    # Make the extracted information accessible
    attr_reader :dirs, :statistics, :total

    # Initialize a new source code statistics displaying handler. When no
    # configurations are passed in directly, we fallback to the configured
    # statistics directories of the gem.
    #
    # @param dirs [Array<Hash{Symbol => Mixed}>] the configurations
    # @return [Countless::SourceStatistics] the new instance
    def initialize(*dirs)
      @dirs = dirs.presence || Countless.configuration.stats_directories
      @statistics = calculate_statistics
      @total = calculate_total if @dirs.length > 1
    end

    # Calculate the total statistics of all sub-statistics for the configured
    # directories.
    #
    # @return [Countless::SourceStatistics::Calculator] the total statistics
    def calculate_total
      calculator = Calculator.new(name: 'Total')
      @statistics.values.each_with_object(calculator) do |conf, total|
        total.add(conf[:stats])
      end
    end

    # Calculate all statistics for the configured directories and pass back a
    # named hash.
    #
    # @return [Hash{String => Hash{Symbol => Mixed}}] the statistics
    #   per configuration
    def calculate_statistics
      @dirs.map do |conf|
        conf[:stats] = calculate_directory_statistics(
          conf[:name],
          conf[:dir],
          conf[:pattern] || Countless.configuration.stats_default_pattern
        )
        [conf[:name], conf]
      end.to_h
    end

    # Setup a new +Calculator+ for the given directory/pattern in order to
    # extract the individual file statistics and calculate the sub-totals.
    #
    # We match the pattern against the individual file name and the relative
    # file path. This allows top-level only matches.
    #
    # @param name [String] the name/description/label of the directory
    # @param dir [String] the directory/path to check
    # @param pattern [RegExp] the file/path pattern to use on individual files
    # @return [Countless::SourceStatistics::Calculator] the calculator runtime
    #   for the given directory/pattern
    #
    # rubocop:disable Metrics/MethodLength because of the recursive
    #   directory/file handling
    # rubocop:disable Metrics/CyclomaticComplexity dito
    # rubocop:disable Metrics/PerceivedComplexity dito
    def calculate_directory_statistics(name, dir, pattern)
      stats = Calculator.new(name: name)

      Dir.foreach(dir) do |file_name|
        next if %w[. ..].include? file_name

        path = "#{dir}/#{file_name}"

        if File.directory?(path) && !file_name.start_with?('.')
          stats.add(calculate_directory_statistics(nil, path, pattern))
        elsif file_name&.match?(pattern) || path&.match?(pattern)
          stats.add_by_file_path(path)
        end
      end

      stats
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    # Calculate the total lines of code.
    #
    # @return [Integer] the total lines of code
    def calculate_code
      @statistics.values.reject { |conf| conf[:test] }
                 .map { |conf| conf[:stats].code_lines }.sum
    end

    # Calculate the total lines of testing code.
    #
    # @return [Integer] the total lines of testing code
    def calculate_tests
      @statistics.values.select { |conf| conf[:test] }
                 .map { |conf| conf[:stats].code_lines }.sum
    end

    # Convert the code statistics to a formatted string buffer.
    #
    # @return [String] the formatted code statistics
    #
    # rubocop:disable Metrics/MethodLength because of the complex formatting
    #   logic with fully dynamic columns widths
    # rubocop:disable Metrics/PerceivedComplexity dito
    # rubocop:disable Metrics/CyclomaticComplexity dito
    # rubocop:disable Metrics/AbcSize dito
    def to_s
      col_sizes = {}
      rows = to_table.map do |row|
        next row unless row.is_a?(Array)

        row = row.map(&:to_s)
        cols = row.map(&:length).each_with_index.map { |len, idx| [idx, [len]] }
        col_sizes.deep_merge!(cols.to_h) { |_, left, right| left + right }
        row
      end

      # Calculate the correct column sizes
      col_sizes = col_sizes.values.each_with_object([]) do |widths, memo|
        memo << widths.max + 2
      end

      # Enforce the correct column sizes per row
      splitter = ([0] + col_sizes + [0]).map { |size| '-' * size }.join('+')
      rows.each_with_object([]) do |row, memo|
        next memo << splitter if row == :splitter
        next memo << row if row.is_a?(String)

        cols = row.each_with_index.map do |col, idx|
          meth = idx.zero? ? :ljust : :rjust
          col.send(meth, col_sizes[idx] - 2)
        end
        memo << "| #{cols.join(' | ')} |"
      end.join("\n")
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    # Convert the code statistics to a processable table structure. Each
    # element in the resulting array is a single line, while array elements
    # reflect columns. The special +:splitter+ row value will be converted
    # later by +#to_s+.
    #
    # @return [Array<Array<String, Integer>, Symbol>] the raw table
    #
    # rubocop:disable Metrics/MethodLength because of the table construction
    def to_table
      table = [
        :splitter,
        %w[Name Lines LOC Classes Methods M/C LOC/M],
        :splitter
      ]
      @statistics.each_value { |conf| table << conf[:stats].to_h.values }
      table << :splitter

      if @total
        table << @total.to_h.values
        table << :splitter
      end

      table << code_test_stats_line
      table
    end
    # rubocop:enable Metrics/MethodLength

    # Return the final meta statistics line.
    #
    # @return [String] the meta statistics line
    def code_test_stats_line
      code  = calculate_code
      tests = calculate_tests
      ratio = tests.fdiv(code)
      ratio = '0' if ratio.nan?

      res = [
        "Code LOC: #{code}",
        "Test LOC: #{tests}",
        "Code to Test Ratio: 1:#{format('%.1f', ratio)}"
      ].join(' ' * 5)
      "  #{res}"
    end

    # The source code statistics calculator which holds a data of a single
    # runtime.
    #
    # Heavily stolen from: https://bit.ly/3tk7ZgJ
    class Calculator
      # Expose each metric as simple readers
      attr_reader :name, :lines, :code_lines, :classes, :methods

      # Setup a new source code statistics calculator instance.
      #
      # @param name [String, nil] the name of the calculated path
      # @param lines [Integer] the initial lines count
      # @param code_lines [Integer] the initial code lines count
      # @param classes [Integer] the initial classes count
      # @param methods [Integer] the initial methods count
      # @return [Countless::SourceStatistics::Calculator] the new instance
      def initialize(name: nil, lines: 0, code_lines: 0, classes: 0, methods: 0)
        @name = name
        @lines = lines
        @code_lines = code_lines
        @classes = classes
        @methods = methods
      end

      # Add the metrics from another calculator instance to the current one.
      #
      # @param calculator [Countless::SourceStatistics::Calculator] the other
      #   calculator instance to fetch metrics from
      def add(calculator)
        @lines += calculator.lines
        @code_lines += calculator.code_lines
        @classes += calculator.classes
        @methods += calculator.methods
      end

      # Parse and add statistics of a single file by path.
      #
      # @param file_path [String] the path of the file
      def add_by_file_path(file_path)
        File.open(file_path) do |fd|
          add_by_io(fd, file_type(file_path))
        end
      end

      # Parse a given input object and extract the corresponding metrics.
      # Afterwards apply the new metrics to the current calculator instance
      # metrics.
      #
      # @param io [IO] the input object to procses line-wise
      # @param file_type [Symbol] the file type to handle
      #
      # rubocop:disable Metrics/MethodLength because of the complex
      #   parsing logic
      # rubocop:disable Metrics/AbcSize dito
      # rubocop:disable Metrics/CyclomaticComplexity dito
      # rubocop:disable Metrics/PerceivedComplexity dito
      def add_by_io(io, file_type)
        patterns = Countless.configuration.stats_patterns[file_type] || {}
        comment_started = false

        while (line = io.gets)
          @lines += 1

          if comment_started
            comment_started = false \
              if patterns[:end_block_comment]&.match?(line)
            next
          elsif patterns[:begin_block_comment]&.match?(line)
            next comment_started = true
          end

          @classes += 1 if patterns[:class]&.match?(line)
          @methods += 1 if patterns[:method]&.match?(line)
          @code_lines += 1 if code_line?(patterns[:line_comment], line)
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      # Check if the given line is a code line by the given pattern. The
      # pattern can be omitted by passing in +nil+.
      #
      # @param pattern [RegExp, nil] the pattern to check
      # @param line [String] the line to check
      # @return [Boolean] whenever the given line is a code line (LOC) or not
      def code_line?(pattern, line)
        !line.match?(/^\s*$/) && (pattern.nil? || !line.match?(pattern))
      end

      # Detect the file type of the given path.
      #
      # @param file_path [String] the path to detect the file type of
      # @return [Symbol] the file type
      def file_type(file_path)
        if file_path.end_with? '_test.rb'
          :minitest
        elsif file_path.end_with? '_spec.rb'
          :rspec
        else
          File.extname(file_path).delete_prefix('.').downcase.to_sym
        end
      end

      # Return the methods per classes.
      #
      # @return [Integer] the methods per classes
      def m_over_c
        suppress(StandardError) { methods / classes } || 0
      end

      # Return the lines of code per methods.
      #
      # @return [Integer] the lines of code per methods
      def loc_over_m
        suppress(StandardError) { code_lines / methods } || 0
      end

      # Convert the current calculator instance to a simple hash.
      #
      # @return [Hash{Symbol => Mixed}] the calculator values as simple hash
      def to_h
        %i[
          name lines code_lines classes methods m_over_c loc_over_m
        ].each_with_object({}) { |key, memo| memo[key] = send(key) }
      end
    end
  end
end
