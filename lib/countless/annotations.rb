# frozen_string_literal: true

module Countless
  # Annotation objects are triplets +:line+, +:tag+, +:text+ that represent the
  # line where the annotation lives, its tag, and its text. Note the filename
  # is not stored.
  #
  # Annotations are looked for in comments and modulus whitespace they have to
  # start with the tag optionally followed by a colon. Everything up to the end
  # of the line (or closing ERB comment tag) is considered to be their text.
  #
  # Heavily stolen from: https://bit.ly/3nBS0aj
  #
  # rubocop:disable Metrics/ClassLength because of the nested Annotation class
  class Annotations
    attr_reader :tag, :options, :dirs, :files, :annotations

    # Setup a new instance of the source annotation extractor.
    #
    # If +tag+ is +nil+, annotations with either default or registered tags are
    # printed.  Specific directories can be explicitly set using the +:dirs+
    # key in +options+.
    #
    #   Countless::SourceAnnotationExtractor.enumerate(
    #     'TODO|FIXME', dirs: %w(app lib), tag: true
    #   )
    #
    # If +options+ has a +:tag+ flag, it will be passed to each annotation's
    # +to_s+. See +#find_in+ for a list of file extensions that will be taken
    # into account.
    #
    # @param tag [String, nil] the annotation tags to use
    # @param options [Hash{Symbol => Mixed}] additional options
    # @return [Countless::SourceAnnotationExtractor] the new instance
    def initialize(tag = nil, options = {})
      @tag = tag || Annotation.tags.join('|')
      @dirs = options.delete(:dirs) || Annotation.directories
      @files = options.delete(:files) || Annotation.files
      @options = options
      @annotations = find(dirs: dirs, files: files)
    end

    # Returns a hash that maps filenames under +dirs+ (recursively) to arrays
    # with their annotations.
    #
    # @param files [Array<String>] the files to use
    # @param dirs [Array<String>] the directories to use
    # @return [Hash{String => Array<Annotation>}] the found annotations per file
    def find(files: [], dirs: [])
      results = {}
      files.inject(results) { |memo, file| memo.update(annotations_in(file)) }
      dirs.inject(results) { |memo, dir| memo.update(find_in(dir)) }
      results
    end

    # Returns a hash that maps filenames under +dir+ (recursively) to arrays
    # with their annotations. Files with extensions registered in
    # +Countless::SourceAnnotationExtractor::Annotation.extensions+ are
    # taken into account. Only files with annotations are included.
    #
    # @param dir [String] the directory to use
    # @return [Hash{String => Array<Annotation>}] the found annotations per file
    def find_in(dir)
      results = {}

      Dir.glob("#{dir}/*") do |item|
        next if File.basename(item)[0] == '.'

        if File.directory?(item)
          results.update(find_in(item))
        else
          results.update(annotations_in(item))
        end
      end

      results
    end

    # Returns a hash that maps filenames under +file+ (de-glob-bed) to arrays
    # with their annotations. Files with extensions registered in
    # +Countless::SourceAnnotationExtractor::Annotation.extensions+ are
    # taken into account. Only files with annotations are included.
    #
    # @param file [String] the file to use
    # @return [Hash{String => Array<Annotation>}] the found annotations per file
    def annotations_in(file)
      results = {}

      Dir.glob(file) do |item|
        extension = \
          Annotation.extensions.detect { |regexp, _block| regexp.match(item) }

        if extension
          pattern = extension.last.call(tag)
          results.update(extract_annotations_from(item, pattern)) if pattern
        end
      end

      results
    end

    # If +file+ is the filename of a file that contains annotations this method
    # returns a hash with a single entry that maps +file+ to an array of its
    # annotations. Otherwise it returns an empty hash.
    #
    # @param file [String] the file path to extract annotations from
    # @param pattern [RegExp] the matching pattern to use
    # @return [Hash{String => Annotation}] the found annotation of the file
    def extract_annotations_from(file, pattern)
      lineno = 0
      result = File.readlines(
        file, encoding: Encoding::BINARY
      ).inject([]) do |list, line|
        lineno += 1
        next list unless line =~ pattern

        list << Annotation.new(lineno, Regexp.last_match(1),
                               Regexp.last_match(2))
      end
      result.empty? ? {} : { file => result }
    end

    # Formats the found annotations.
    #
    # @return [String] the formatted annotations
    #
    # rubocop:disable Metrics/AbcSize because of the indentation logic
    def to_s
      buf = []
      options[:indent] = annotations.flat_map do |_f, a|
        a.map(&:line)
      end.max.to_s.size
      annotations.keys.sort.each do |file|
        buf << "#{file}:"
        annotations[file].each { |note| buf << "  * #{note.to_s(options)}" }
        buf << ''
      end
      buf.join("\n")
    end
    # rubocop:enable Metrics/AbcSize

    # A single annotation representation.
    Annotation = Struct.new(:line, :tag, :text) do
      # Returns the currently configured files.
      #
      # @return [Array<String>] the configured files
      def self.files
        @files ||= \
          Countless.configuration.annotations_files.deep_dup
      end

      # Registers additional files to be included.
      #
      # @param dirs [Array<String>] the additional files to include
      def self.register_files(*dirs)
        files.push(*dirs)
      end

      # Returns the currently configured directories.
      #
      # @return [Array<String>] the configured directories
      def self.directories
        @directories ||= \
          Countless.configuration.annotations_directories.deep_dup
      end

      # Registers additional directories to be included.
      #
      # @param dirs [Array<String>] the additional directories to include
      def self.register_directories(*dirs)
        directories.push(*dirs)
      end

      # Returns the currently configured tags.
      #
      # @return [Array<String>] the configured tags
      def self.tags
        @tags ||= Countless.configuration.annotation_tags.deep_dup.map do |tag|
          "@?#{tag}"
        end
      end

      # Registers additional tags.
      #
      # @param additional_tags [Array<String>] the additional tags to include
      def self.register_tags(*additional_tags)
        tags.push(*additional_tags)
      end

      # Returns the currently configured file extension handlers.
      #
      # @return [Hash<RegExp => Proc>] the configured file extension handlers
      def self.extensions
        @extensions ||= begin
          patterns = Countless.configuration.annotation_patterns.values
          patterns.map do |conf|
            [
              extensions_regexp(conf[:extensions], conf[:files] || []),
              conf[:regex]
            ]
          end.to_h
        end
      end

      # Registers new annotations file extension handlers.
      #
      # @param exts [Array<String>] the file extensions to match
      # @param block [Proc] the line/comment/annotation matching block
      def self.register_extensions(*exts, &block)
        extensions[extensions_regexp(exts)] = block
      end

      # Build a new extension regexp of the given extensions.
      #
      # @param exts [Array<String>] the file extensions to join
      # @param files [Array<String>] a list of dedicated files
      # @return [RegExp] the extensions matching regexp
      def self.extensions_regexp(exts, files = [])
        exts = /\.(#{exts.join('|')})$/
        return exts if files.empty?

        Regexp.union(/^#{files.join('|')}$/, exts)
      end

      # Returns a representation of the annotation that looks like this:
      #
      #   [126] [TODO] This algorithm is nice and simple, make it faster.
      #
      # If +options+ has a flag +:tag+ the tag is shown as in the example
      # above.  Otherwise the string contains just line and text.  When
      # +options+ has a value for +:indent+ the line number block will be
      # right-justified.
      #
      # @param options [Hash{Symbol => Mixed}] the additional options
      def to_s(options = {})
        s = +"[#{line.to_s.rjust(options[:indent])}] "
        s << "[#{tag}] " if options[:tag]
        s << text
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
