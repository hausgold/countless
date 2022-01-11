# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'pp'

desc 'Report code statistics (KLOCs, etc)'
task :stats do
  puts Countless::SourceStatistics.new.to_s
end

desc 'Enumerate all annotations'
task :notes do
  puts Countless::SourceAnnotationExtractor.new.to_s
end

namespace :notes do
  Countless.configuration.annotation_tags.each do |annotation|
    task annotation.downcase.intern do
      puts Countless::SourceAnnotationExtractor.new("@?#{annotation}").to_s
    end
  end

  task :custom do
    annotation = ENV.fetch('ANNOTATION')
    puts Countless::SourceAnnotationExtractor.new("@?#{annotation}").to_s
  rescue KeyError
    puts 'No annotation was specified.'
    puts "Usage: ANNOTATION='FIXME' rake notes:custom"
    exit 1
  end
end
