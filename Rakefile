# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'countless/rake_tasks'

# TODO: This is just for testing purposes
#       here. Keep it exactly like that.

RSpec::Core::RakeTask.new(:spec).tap do |task|
  task.exclude_pattern = 'spec/fixtures/**/*'
end

task default: :spec

# Configure all code statistics directories
Countless.configure do |config|
  config.stats_base_directories = [
    { name: 'Top-levels', dir: 'lib',
      pattern: %r{/lib(/countless)?/[^/]+\.(rb|rake)$} },
    { name: 'Top-levels specs', test: true, dir: 'spec',
      pattern: %r{/spec(/countless)?/[^/]+_spec\.rb$} },
    { name: 'Extensions', pattern: 'lib/countless/extensions/**/*.rb' },
    { name: 'Extensions specs', test: true,
      pattern: 'spec/countless/extensions/**/*_spec.rb' }
  ]
end
