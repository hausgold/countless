# frozen_string_literal: true

require 'simplecov'
SimpleCov.command_name 'specs'

require 'bundler/setup'
require 'yaml'

Rake = OpenStruct.new(
  application: OpenStruct.new(
    rakefile_location: File.expand_path(File.join(__dir__, '../'))
  )
)

require 'countless'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Enable the focus inclusion filter and run all when no filter is set
  # See: http://bit.ly/2TVkcIh
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
end

# Print some information
puts
puts <<DESC
  -------------- Versions --------------
            Ruby: #{RUBY_VERSION}
  Active Support: #{ActiveSupport.version}
  --------------------------------------
DESC
puts

# Fetch a file fixture by name/path.
#
# @param path [String, Symbol] the path to fetch
# @return [Pathname] the found file fixture
def file_fixture(path)
  Pathname.new(File.expand_path(File.join(__dir__, "fixtures/files/#{path}")))
end
