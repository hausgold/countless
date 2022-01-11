# frozen_string_literal: true

=begin
  Yay. A
  multi
  line
  comment
=end
require 'pp'
require 'rspec/core/rake_task'

def noop
  true
end

task :default do
  pp 'This is the default task.'
  # Comment
  pp 'Yay.'
end
