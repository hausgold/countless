# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/kernel/reporting'

require 'countless/version'

# The top level namespace for the countless gem.
module Countless
  # Top level elements
  autoload :Configuration, 'countless/configuration'
  autoload :SourceAnnotationExtractor, 'countless/source_annotation_extractor'
  autoload :SourceStatistics, 'countless/source_statistics'

  # rubocop:disable Style/ClassVars because we're in a module here
  class << self
    # Retrieve the current configuration object.
    #
    # @return [Configuration] the current configuration object
    def configuration
      @@configuration ||= Configuration.new
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
      @@configuration = Configuration.new
    end
  end
  # rubocop:enable Style/ClassVars
end
