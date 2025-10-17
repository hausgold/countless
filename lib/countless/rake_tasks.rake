# frozen_string_literal: true

desc 'Report code statistics (KLOCs, etc)'
task :stats do
  puts Countless::Statistics.new
end

desc 'Enumerate all annotations'
task :notes do
  puts Countless::Annotations.new
end

namespace :notes do
  Countless.configuration.annotation_tags.each do |annotation|
    task annotation.downcase.to_sym do
      puts Countless::Annotations.new("@?#{annotation}")
    end
  end

  task :custom do
    annotation = ENV.fetch('ANNOTATION')
    puts Countless::Annotations.new("@?#{annotation}")
  rescue KeyError
    puts 'No annotation was specified.'
    puts "Usage: ANNOTATION='FIXME' rake notes:custom"
    exit 1
  end
end
