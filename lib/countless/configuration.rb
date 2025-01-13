# frozen_string_literal: true

module Countless
  # The configuration for the countless gem.
  #
  # rubocop:disable Metrics/ClassLength because of the various defaults
  # rubocop:disable Metrics/BlockLength ditoditodito
  class Configuration
    include ActiveSupport::Configurable

    # The base/root path of the project to work on. This path is used as a
    # prefix to all relative path/file configurations.
    config_accessor(:base_path) do
      # Check for a Rake invoked call
      if defined?(Rake) && Rake.respond_to?(:application)
        path = Rake.application.rakefile_location
        path ||= Rake.application.original_dir
        next path if path.present?
      end

      # Check for Rails as fallback
      next Rails.root if defined? Rails

      # Use the current working directory
      # of the process as last resort
      Dir.pwd
    end

    # The path to the CLOC (https://github.com/AlDanial/cloc) binary. The gem
    # comes with a bundled version of the utility, ready to be used. But you
    # can also change the used binary path in order to use a different version
    # which you manually provisioned.
    config_accessor(:cloc_path) { File.expand_path('../../bin/cloc', __dir__) }

    # We allow to configure additional file extensions to consider for
    # statistics calculation. They will be included in the default list. This
    # way you can easily extend the list.
    config_accessor(:additional_stats_file_extensions) { [] }

    # All the file extensions to consider for statistics calculation
    config_accessor(:stats_file_extensions) do
      %w[rb js jsx ts tsx css scss coffee rake erb haml h c cpp rs] +
        additional_stats_file_extensions
    end

    # We allow to configure additional application object types. They will be
    # included in the default list. This way you can easily extend the list.
    config_accessor(:additional_stats_app_object_types) { [] }

    # Configure the application (in the root +app+ directory) object types,
    # they will be added as regular directories as well as their testing
    # counter parts (minitest/RSpec)
    config_accessor(:stats_app_object_types) do
      %w[channels consumers controllers dashboards decorators fields helpers
         jobs mailboxes mailers models policies serializers services uploaders
         validators value_objects views] + additional_stats_app_object_types
    end

    # We allow to configure additional statistics directories. They will be
    # included in the default list. This way you can easily extend the list.
    config_accessor(:additional_stats_directories) { [] }

    # A list of custom base directories in an application / gem
    config_accessor(:stats_base_directories) do
      [
        { name: 'JavaScripts', dir: 'app/assets/javascripts' },
        { name: 'Stylesheets', dir: 'app/assets/stylesheets' },
        { name: 'JavaScript', dir: 'app/javascript' },
        { name: 'API', dir: 'app/api' },
        { name: 'API tests', dir: 'test/api', test: true },
        { name: 'API specs', dir: 'spec/api', test: true },
        { name: 'APIs', dir: 'app/apis' },
        { name: 'API tests', dir: 'test/apis', test: true },
        { name: 'API specs', dir: 'spec/apis', test: true },
        { name: 'Libraries', dir: 'app/lib' },
        { name: 'Library tests', dir: 'test/lib', test: true },
        { name: 'Library specs', dir: 'spec/lib', test: true },
        { name: 'Libraries', dir: 'lib' },
        { name: 'Library tests', dir: 'test/lib', test: true },
        { name: 'Library specs', dir: 'spec/lib', test: true }
      ] + additional_stats_directories
    end

    # We allow to configure additional detailed statistics patterns. They will
    # be included in the default list. This way you can easily extend the list.
    config_accessor(:additional_detailed_stats_patterns) { {} }

    # All the detailed statistics (class/method and tests/examples) patterns
    # which will be used for parsing the source files to gather the metrics
    config_accessor(:detailed_stats_patterns) do
      {
        ruby: {
          extensions: %w[rb rake],
          class: /^\s*class\s+[_A-Z]/, # regular Ruby classes
          method: Regexp.union(
            [
              /^\s*def\s+[_a-z]/, # regular Ruby methods
              /^\s*def test_/, # minitest
              /^\s*x?it(\s+|\()['"_a-z]/ # RSpec
            ]
          )
        },
        javascript: {
          extensions: %w[js jsx ts tsx],
          class: /^\s*class\s+[_A-Z]/,
          method: Regexp.union(
            [
              /function(\s+[_a-zA-Z][\da-zA-Z]*)?\s*\(/, # regular method
              /^\s*x?it(\s+|\()['"_a-z]/, # jsspec, jasmine, jest
              /^\s*test(\s+|\()['"_a-z]/, # jest
              /^\s*QUnit.test(\s+|\()['"_a-z]/ # qunit
            ]
          )
        },
        coffee: {
          extensions: %w[coffee],
          class: /^\s*class\s+[_A-Z]/,
          method: /[-=]>/
        },
        rust: {
          extensions: %(rs),
          class: /^\s*struct\s+[_A-Z]/,
          method: Regexp.union(
            [
              /^\s*fn\s+[_a-z]/, # regular Rust methods
              /#\[test\]/ # methods with test config
            ]
          )
        },
        c_cpp: {
          extensions: %(h c cpp),
          class: /^\s*(struct|class)\s+[_a-z]/i,
          method: /^\s*\w.* \w.*\(.*\)\s*{/m
        }
      }.deep_merge(additional_detailed_stats_patterns)
    end

    # We allow to configure additional annotation directories. They will be
    # included in the default list. This way you can easily extend the list.
    config_accessor(:additional_annotations_directories) { [] }

    # Configure the directories which should be checked for annotations
    config_accessor(:annotations_directories) do
      %w[app config db src lib test tests spec doc docs] +
        additional_annotations_directories
    end

    # We allow to configure additional annotation files/patterns. They will be
    # included in the default list. This way you can easily extend the list.
    config_accessor(:additional_annotations_files) { [] }

    # Configure the files/patterns which should be checked for annotations
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
      ] + additional_annotations_files
    end

    # We allow to configure additional annotation tags. They will be included
    # in the default list. This way you can easily extend the list.
    config_accessor(:additional_annotation_tags) { [] }

    # Configure the annotation tags which will be search
    config_accessor(:annotation_tags) do
      %w[OPTIMIZE FIXME TODO TESTME DEPRECATEME] + additional_annotation_tags
    end

    # We allow to configure additional annotation patterns. They will be
    # included in the default list. This way you can easily extend the list.
    config_accessor(:additional_annotation_patterns) { {} }

    # Configure all known file extensions of annotations files
    config_accessor(:annotation_patterns) do
      {
        hashtag: {
          files: %w[Appraisals Dockerfile Envfile Gemfile Rakefile
                    Makefile Appraisals],
          extensions: %w[builder md ru rb rake yml yaml ruby gemspec toml],
          regex: ->(tag) { /#\s*(#{tag}):?\s*(.*)$/ }
        },
        double_slash: {
          extensions: %w[css js jsx ts tsx rust c h],
          regex: ->(tag) { %r{//\s*(#{tag}):?\s*(.*)$} }
        },
        erb: {
          extensions: %w[erb],
          regex: ->(tag) { /<%\s*#\s*(#{tag}):?\s*(.*?)\s*%>/ }
        },
        haml: {
          extensions: %w[haml],
          regex: ->(tag) { /-#\s*(#{tag}):?\s*(.*)$/ }
        }
      }.deep_merge(additional_annotation_patterns)
    end
  end
  # rubocop:enable Metrics/ClassLength
  # rubocop:enable Metrics/BlockLength
end
