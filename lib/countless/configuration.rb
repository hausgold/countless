# frozen_string_literal: true

module Countless
  # The configuration for the countless gem.
  #
  # rubocop:disable Metrics/ClassLength because of the various defaults
  # rubocop:disable Metrics/BlockLength dito
  # rubocop:disable Metrics/AbcSize dito
  # rubocop:disable Metrics/MethodLength dito
  class Configuration
    include ActiveSupport::Configurable

    # All the statistics patterns which will be used for parsing the
    # source files to gather the metrics
    config_accessor(:stats_patterns) do
      {
        rb: {
          line_comment: /^\s*#/,
          begin_block_comment: /^=begin/,
          end_block_comment: /^=end/,
          class: /^\s*class\s+[_A-Z]/,
          method: /^\s*def\s+[_a-z]/
        },
        erb: {
          line_comment: /((^\s*<%#.*%>)|(<!--.*-->))/
        },
        haml: {
          line_comment: /^\s*-#/
        },
        css: {
          line_comment: %r{^\s*/\*.*\*/},
          begin_block_comment: %r{^\s*/\*.*(?<!\*/)$},
          end_block_comment: %r{\*/}
        },
        scss: {
          line_comment: %r{((^\s*/\*.*\*/)|(^\s*//))},
          begin_block_comment: %r{^\s*/\*.*(?<!\*/)$},
          end_block_comment: %r{\*/}
        },
        js: {
          line_comment: %r{((^\s*/\*.*\*/)|(^\s*//))},
          begin_block_comment: %r{^\s*/\*.*(?<!\*/)$},
          end_block_comment: %r{\*/},
          class: /^\s*class\s+[_A-Z]/,
          method: /function(\s+[_a-zA-Z][\da-zA-Z]*)?\s*\(/
        },
        coffee: {
          line_comment: /^\s*#/,
          begin_block_comment: /^\s*###/,
          end_block_comment: /^\s*###/,
          class: /^\s*class\s+[_A-Z]/,
          method: /[-=]>/
        }
      }.tap do |patterns|
        patterns[:rake] = patterns[:rb]
        patterns[:ts] = patterns[:jsx] = patterns[:tsx] = patterns[:js]
        patterns[:minitest] = patterns[:rb].merge(
          method: /^\s*(def|test)\s+['"_a-z]/
        )
        patterns[:rspec] = patterns[:rb].merge(
          method: /^\s*(def|x?it)\s+['"_a-z]/
        )
      end
    end

    # All the file extensions to consider for statistics calculation
    config_accessor(:stats_file_extensions) do
      %w[rb js ts jsx tsx css scss coffee rake erb haml]
    end

    # This pattern is used on configured statistics directories without
    # explicitly configured pattern
    config_accessor(:stats_default_pattern) do
      /^(?!\.).*?\.(#{stats_file_extensions.join('|')})$/
    end

    # Configure the application (in the root +app+ directory) class types,
    # they will be added as regular directories as well as their testing
    # counter parts (minitest/RSpec)
    config_accessor(:stats_app_file_types) do
      %w[
        channels
        consumers
        controllers
        dashboards
        decorators
        fields
        helpers
        jobs
        mailboxes
        mailers
        models
        policies
        serializers
        services
        uploaders
        validators
        value_objects
        views
      ]
    end

    # A list of custom base directories in an application / gem
    config_accessor(:stats_base_directories) do
      [
        { name: 'JavaScripts', dir: 'app/assets/javascripts' },
        { name: 'Stylesheets', dir: 'app/assets/stylesheets' },
        { name: 'JavaScript', dir: 'app/javascript' }
      ].tap do |base|
        [
          ['API', 'api/'],
          ['APIs', 'apis/'],
          ['Libraries', 'lib/']
        ].each do |name, dir|
          base << { name: name, dir: "app/#{dir}" }
          base << { name: "#{name} tests", dir: "test/#{dir}", test: true }
          base << { name: "#{name} specs", dir: "spec/#{dir}", test: true }
        end
      end
    end

    # A simple list of addtional user defined directories to check
    config_accessor(:stats_additional_directories) { [] }

    # Get an assembled list of directories which should be checked for KLOC
    # statistics.
    #
    # @return [Array<Hash{Symbol => Mixed}>] the statistics directories
    def stats_directories
      res = stats_base_directories.deep_dup
      res += stats_additional_directories.deep_dup

      stats_app_file_types.each do |type|
        one_type = type.singularize
        many_types = type.pluralize

        res << { name: many_types.capitalize, dir: "app/#{type}" }
        res << { name: "#{one_type.capitalize} tests",
                 dir: "test/#{type}", test: true }
        res << { name: "#{one_type.capitalize} specs",
                 dir: "specs/#{type}", test: true }
      end

      base_dir = File.dirname(Rake.application.rakefile_location)
      res.each do |conf|
        conf[:pattern] ||= stats_default_pattern
        conf[:test] ||= false
        conf[:dir] = "#{base_dir}/#{conf[:dir]}"
      end

      res.select { |conf| File.directory? conf[:dir] }
         .sort_by { |conf| [conf[:test].to_s, conf[:name]] }
    end

    # Configure the directories/files which should be checked for annotations
    config_accessor(:annotations_directories) do
      %w[app config db lib test spec doc docs]
    end
    config_accessor(:annotations_files) do
      %w[
        Appraisals
        CHANGELOG.md
        CODE_OF_CONDUCT.md
        config.ru
        docker-compose.yml
        Dockerfile
        Envfile
        Gemfile
        *.gemspec
        Makefile
        Rakefile
        README.md
      ]
    end

    # Configure the annotation tags which will be search
    config_accessor(:annotation_tags) do
      %w[OPTIMIZE FIXME TODO TESTME DEPRECATEME]
    end

    # Configure all known file extensions of annotations files
    config_accessor(:annotation_extensions) do
      {
        %w[builder md ru rb rake yml yaml ruby gemspec Appraisals Dockerfile
           Envfile Gemfile Rakefile Makefile Appraisals] => \
          proc { |tag| /#\s*(#{tag}):?\s*(.*)$/ },
        %w[css js] => \
          proc { |tag| %r{//\s*(#{tag}):?\s*(.*)$} },
        %w[erb] => \
          proc { |tag| /<%\s*#\s*(#{tag}):?\s*(.*?)\s*%>/ }
      }
    end
  end
  # rubocop:enable Metrics/ClassLength
  # rubocop:enable Metrics/BlockLength
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
