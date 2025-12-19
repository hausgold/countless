# frozen_string_literal: true

module Countless
  module Extensions
    # A top-level gem-module extension to handle configuration needs.
    module ConfigurationHandling
      extend ActiveSupport::Concern

      class_methods do
        # Retrieve the current configuration object.
        #
        # @return [Configuration] the current configuration object
        def configuration
          @configuration ||= Configuration.new
        end

        # Configure the concern by providing a block which takes
        # care of this task. Example:
        #
        #   Countless.configure do |conf|
        #     # conf.xyz = [..]
        #   end
        def configure
          yield(configuration)
        end

        # Reset the current configuration with the default one.
        def reset_configuration!
          @configuration = Configuration.new
        end

        # A shortcut to the configured CLOC binary.
        delegate :cloc_path, to: :configuration

        # Get an assembled list of directories which should be
        # checked for code statistics.
        #
        # @return [Array<Hash{Symbol => Mixed}>] the statistics directories
        def statistic_directories
          conf = configuration
          pattern_suffix = "/**/*.{#{conf.stats_file_extensions.join(',')}}"

          res = conf.stats_base_directories.deep_dup
          conf.stats_app_object_types.each do |type|
            one_type = type.singularize.titleize
            many_types = type.pluralize.titleize

            res << { name: many_types, dir: "app/#{type}" }
            res << { name: "#{one_type} tests",
                     dir: "test/#{type}", test: true }
            res << { name: "#{one_type} specs",
                     dir: "specs/#{type}", test: true }
          end

          res.each do |cur|
            # Add the configured base dir, when we hit a relative dir config
            cur[:dir] = "#{conf.base_path}/#{cur[:dir]}" \
              unless (cur[:dir] || '').start_with? '/'
            # Add the default pattern, when no user configured pattern
            # is present
            cur[:pattern] ||= "#{cur[:dir]}#{pattern_suffix}"
            # Fallback to regular code, when not otherwise configured
            cur[:test] ||= false
          end

          res.sort_by { |cur| [cur[:test].to_s, cur[:name]] }
        end
      end
    end
  end
end
