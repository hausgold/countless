# frozen_string_literal: true

require 'rspec/core/rake_task'

desc 'Report code statistics (KLOCs, etc)'
task :stats do
  puts Countless::Statistics.new.to_s
end

desc 'Enumerate all annotations'
task :notes do
  puts Countless::Annotations.new.to_s
end

namespace :notes do
  Countless.configuration.annotation_tags.each do |annotation|
    task annotation.downcase.to_sym do
      puts Countless::Annotations.new("@?#{annotation}").to_s
    end
  end

  task :custom do
    annotation = ENV.fetch('ANNOTATION')
    puts Countless::Annotations.new("@?#{annotation}").to_s
  rescue KeyError
    puts 'No annotation was specified.'
    puts "Usage: ANNOTATION='FIXME' rake notes:custom"
    exit 1
  end
end
