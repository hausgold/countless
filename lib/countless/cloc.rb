# frozen_string_literal: true

module Countless
  # A simple wrapper around the CLOC utility.
  class Cloc
    class << self
      # Extract code statistics from the given files with CLOC. Each key of the
      # resulting hash is the file path which was inspected. Each value of the
      # resulting hash contains the raw statistic numbers (blank, comment,
      # code, total).
      #
      # Example:
      #
      #   {
      #     "/app/lib/countless/configuration.rb" => {
      #       :blank=>24, :comment=>43, :code=>141, :total=>208
      #     }
      #   }
      #
      # @return [Hash{String => Hash{Symbol => Integer}}] the
      #   re-structured CLOC statistics
      def stats(*paths)
        raw_stats(*paths).except('SUM', 'header').transform_values do |obj|
          obj.symbolize_keys.except(:language).tap do |stats|
            stats[:total] = stats.values.sum
          end
        end
      end

      # Fetch the raw statistics via CLOC for the given paths.
      #
      # @param paths [Array<String, Pathname>] the paths (files or
      #   directories) to fetch the statistics for
      # @return [Hash{String => Hash{String => Mixed}] the raw CLOC
      #   YAML output
      #
      # rubocop:disable Metrics/MethodLength because of the system
      #   command preparation
      def raw_stats(*paths)
        cmd = [
          Countless.cloc_path,
          '--quiet',
          '--by-file',
          '--yaml',
          '--list-file -',
          '2>/dev/null'
        ].join(' ')

        # We pipe in the file list via stdin to cloc, this allows us to
        # pass large file lists down (ARGV is size limited)
        stdout = IO.popen(cmd, File::RDWR) do |io|
          paths.each { |path| io.puts(path) }
          io.close_write
          io.read
        end

        # When the system command was not successful,
        # we return an fallback result
        return {} unless $CHILD_STATUS.success?

        # Otherwise we use the CLOC produced YAML and parse it
        YAML.safe_load(stdout) || {}
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
