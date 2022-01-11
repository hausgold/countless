#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'yaml'
require 'countless'

# pp Countless::Cloc.stats(File.expand_path('../lib', __dir__),
#                          *Dir['spec/**/*.rb'])

# pp Countless.statistic_directories

# pp Countless::Statistics.new

puts Countless::Statistics.new.to_s
