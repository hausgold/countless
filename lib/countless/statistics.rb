# frozen_string_literal: true

module Countless
  # The source code statistics displaying handler.
  #
  # Heavily stolen from: https://bit.ly/3qpvgfu
  #
  # rubocop:disable Metrics/ClassLength -- because of the calculation and
  #   formatting logic
  class Statistics
    # Make the extracted information accessible
    attr_reader :dirs, :statistics, :total

    # Initialize a new source code statistics displaying handler. When no
    # configurations are passed in directly, we fallback to the configured
    # statistics directories of the gem.
    #
    # @param dirs [Array<Hash{Symbol => Mixed}>] the configurations
    # @return [Countless::Statistics] the new instance
    #
    # rubocop:disable Metrics/AbcSize -- because of the directory/config
    #   resolving
    # rubocop:disable Metrics/PerceivedComplexity -- ditto
    # rubocop:disable Metrics/CyclomaticComplexity -- ditto
    # rubocop:disable Metrics/MethodLength -- ditto
    def initialize(*dirs)
      base_path = Countless.configuration.base_path

      # Resolve the given directory configurations to actual files
      dirs = dirs.presence || Countless.statistic_directories
      @dirs = dirs.each_with_object([]) do |cur, memo|
        copy = cur.deep_dup
        copy[:files] = Array(copy[:files])

        if copy[:pattern].is_a? Regexp
          copy[:files] += Dir[
            File.join(copy[:dir] || base_path, '**/*')
          ].select { |path| File.file?(path) && copy[:pattern].match?(path) }
        else
          copy[:files] += Dir[copy[:pattern]]
        end

        copy[:files].uniq!
        memo << copy if copy[:files].present?
      end

      @statistics = calculate_statistics
      @total = calculate_total if @dirs.length > 1
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength

    # Calculate the total statistics of all sub-statistics for the configured
    # directories.
    #
    # @return [Countless::Statistics::Calculator] the total statistics
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
      @dirs.to_h do |conf|
        [
          conf[:name],
          conf.merge(stats: calculate_file_statistics(conf[:name],
                                                      conf[:files]))
        ]
      end
    end

    # Setup a new +Calculator+ for the given directory/pattern in order to
    # extract the individual file statistics and calculate the sub-totals.
    #
    # We match the pattern against the individual file name and the relative
    # file path. This allows top-level only matches.
    #
    # @param name [String] the name/description/label of the directory
    # @param files [Array<String, Pathname>] the files to extract
    #   statistics from
    # @return [Countless::Statistics::Calculator] the calculator runtime
    #   for the given directory/pattern
    def calculate_file_statistics(name, files)
      Calculator.new(name: name).tap do |calc|
        Cloc.stats(*files).each do |path, stats|
          calc.add_by_file_path(path, **stats)
        end
      end
    end

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
    # rubocop:disable Metrics/MethodLength -- because of the complex formatting
    #   logic with fully dynamic columns widths
    # rubocop:disable Metrics/PerceivedComplexity -- ditto
    # rubocop:disable Metrics/CyclomaticComplexity -- ditto
    # rubocop:disable Metrics/AbcSize -- ditto
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
        memo << (widths.max + 2)
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
    # rubocop:disable Metrics/MethodLength -- because of the table construction
    def to_table
      table = [
        :splitter,
        %w[Name Lines LOC Comments Classes Methods M/C LOC/M],
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

    # The source code statistics calculator which holds the data of a single
    # runtime.
    #
    # Heavily stolen from: https://bit.ly/3tk7ZgJ
    class Calculator
      # Expose each metric as simple readers
      attr_reader :name, :lines, :code_lines, :comment_lines,
                  :classes, :methods

      # Setup a new source code statistics calculator instance.
      #
      # @param name [String, nil] the name of the calculated path
      # @param lines [Integer] the initial lines count
      # @param code_lines [Integer] the initial code lines count
      # @param comment_lines [Integer] the initial comment lines count
      # @param classes [Integer] the initial classes count
      # @param methods [Integer] the initial methods count
      # @return [Countless::Statistics::Calculator] the new instance
      #
      # rubocop:disable Metrics/ParameterLists -- because of the various
      #   metrics we support
      def initialize(name: nil, lines: 0, code_lines: 0, comment_lines: 0,
                     classes: 0, methods: 0)
        @name = name
        @lines = lines
        @code_lines = code_lines
        @comment_lines = comment_lines
        @classes = classes
        @methods = methods
      end
      # rubocop:enable Metrics/ParameterLists

      # Add the metrics from another calculator instance to the current one.
      #
      # @param calculator [Countless::Statistics::Calculator] the other
      #   calculator instance to fetch metrics from
      def add(calculator)
        @lines += calculator.lines
        @code_lines += calculator.code_lines
        @comment_lines += calculator.comment_lines
        @classes += calculator.classes
        @methods += calculator.methods
      end

      # Parse and add statistics of a single file by path.
      #
      # @param path [String] the path of the file
      # @param stats [Hash{Symbol => Integer}] addtional CLOC statistics
      def add_by_file_path(path, **stats)
        @lines += stats.fetch(:total, 0)
        @code_lines += stats.fetch(:code, 0)
        @comment_lines += stats.fetch(:comment, 0)
        add_details_by_file_path(path)
      end

      # Analyse a given input file and extract the corresponding detailed
      # metrics. (class and method counts) Afterwards apply the new metrics to
      # the current calculator instance metrics.
      #
      # @param path [String] the path of the file
      #
      # rubocop:disable Metrics/AbcSize -- because of the pattern search by
      #   file extension and pattern matching on each line afterwards
      # rubocop:disable Metrics/CyclomaticComplexity -- ditto
      # rubocop:disable Metrics/PerceivedComplexity -- ditto
      def add_details_by_file_path(path)
        all_patterns = Countless.configuration.detailed_stats_patterns

        ext = path.split('.').last
        patterns = all_patterns.find do |_, conf|
          conf[:extensions].include? ext
        end&.last

        # When no detailed patterns are configured for this file,
        # we skip further processing
        return unless patterns

        # Walk through the given file, line by line
        File.read(path).lines.each do |line|
          @classes += 1 if patterns[:class]&.match? line
          @methods += 1 if patterns[:method]&.match? line
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      # Return the methods per classes.
      #
      # @return [Integer] the methods per classes
      def m_over_c
        methods / classes
      rescue StandardError
        0
      end

      # Return the lines of code per methods.
      #
      # @return [Integer] the lines of code per methods
      def loc_over_m
        code_lines / methods
      rescue StandardError
        0
      end

      # Convert the current calculator instance to a simple hash.
      #
      # @return [Hash{Symbol => Mixed}] the calculator values as simple hash
      def to_h
        %i[
          name lines code_lines comment_lines
          classes methods m_over_c loc_over_m
        ].each_with_object({}) { |key, memo| memo[key] = send(key) }
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
