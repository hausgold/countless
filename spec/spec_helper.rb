# frozen_string_literal: true

require 'simplecov'
SimpleCov.command_name 'specs'

# Test Env
env = ENV['GITHUB_ACTIONS'].nil? ? :test : :github_actions

require 'bundler/setup'
require 'countless'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Print some information
puts
puts <<DESC
  -------------- Versions --------------
  Active Support: #{ActiveSupport.version}
  --------------------------------------
DESC
puts
