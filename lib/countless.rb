# frozen_string_literal: true

require 'zeitwerk'
require 'logger'
require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/enumerable'
require 'yaml'
require 'English'
require 'shellwords'

# The top level namespace for the countless gem.
module Countless
  # Configure the relative gem code base location
  root_path = Pathname.new("#{__dir__}/countless")

  # Setup a Zeitwerk autoloader instance and configure it
  loader = Zeitwerk::Loader.for_gem

  # Do not automatically load the Rake tasks
  loader.ignore("#{__dir__}/countless/rake_tasks.rb")
  loader.do_not_eager_load(root_path.join('configuration.rb'))

  # Finish the auto loader configuration
  loader.setup

  # Load standalone code
  require 'countless/version'

  # Include top-level features
  include Extensions::ConfigurationHandling

  # Make sure to eager load all constants
  loader.eager_load
end
