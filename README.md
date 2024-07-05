![Countless](doc/assets/project.svg)

[![Continuous Integration](https://github.com/hausgold/countless/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/hausgold/countless/actions/workflows/test.yml)
[![Gem Version](https://badge.fury.io/rb/countless.svg)](https://badge.fury.io/rb/countless)
[![Test Coverage](https://automate-api.hausgold.de/v1/coverage_reports/countless/coverage.svg)](https://knowledge.hausgold.de/coverage)
[![Test Ratio](https://automate-api.hausgold.de/v1/coverage_reports/countless/ratio.svg)](https://knowledge.hausgold.de/coverage)
[![API docs](https://automate-api.hausgold.de/v1/coverage_reports/countless/documentation.svg)](https://www.rubydoc.info/gems/countless)

This is a reusable and widely configurable collection of
[Rake](https://ruby.github.io/rake/) tasks and utilities for code statistics
and annotations. The Rake task names and outputs are based on the Rails tasks.
For code statistics (lines of code, comments) the
[cloc](https://github.com/AlDanial/cloc) utility is used, which is
battle-proven, popular and good maintained. A bundled version of it is shipped
with the gem package.

- [Installation](#installation)
- [Requirements](#requirements)
- [Usage](#usage)
  - [Addtional Configuration](#addtional-configuration)
- [Development](#development)
- [Code of Conduct](#code-of-conduct)
- [Contributing](#contributing)
- [Releasing](#releasing)

## Installation

Add this line to your gemspec/Gemfile:

```ruby
# Within a gem/library use:
spec.add_runtime_dependency 'countless'

# In an application use:
gem 'countless'
```

And then execute:

```bash
$ bundle
```

## Requirements

* [Ruby](https://www.ruby-lang.org/) (>=2.7, tested on CRuby/MRI only, may work
  with other implementations as well)
* [Perl](https://www.perl.org/) (>= 5.10, for the
  [cloc](https://github.com/AlDanial/cloc) utility)

## Usage

You can configure the Countless gem in serveral ways, but the most common
usecase is to install its Rake tasks and configure it in order to work
properly. Here comes a self descriptive example (within a Rakefile):

```ruby
# Add the annotations and statistics tasks
require 'countless/rake_tasks'
```

Afterwards the following Rake tasks are available to you:

* **stats**: Report code statistics (KLOCs, etc) (run via `bundle exec rake stats`)
  ```
  +------------------+-------+-----+----------+---------+---------+-----+-------+
  | Name             | Lines | LOC | Comments | Classes | Methods | M/C | LOC/M |
  +------------------+-------+-----+----------+---------+---------+-----+-------+
  | Extensions       |    83 |  40 |       33 |       0 |       4 |   0 |    10 |
  | Top-levels       |   934 | 503 |      331 |       5 |      36 |   7 |    13 |
  | Extensions specs |    36 |  28 |        1 |       0 |       4 |   0 |     7 |
  | Top-levels specs |   323 | 260 |        4 |       0 |      39 |   0 |     6 |
  +------------------+-------+-----+----------+---------+---------+-----+-------+
  | Total            |  1376 | 831 |      369 |       5 |      83 |  16 |    10 |
  +------------------+-------+-----+----------+---------+---------+-----+-------+
    Code LOC: 543     Test LOC: 288     Code to Test Ratio: 1:0.5
  ```
* **notes**: Enumerate all annotations (run via `bundle exec rake notes`)
  ```
  Rakefile:
    * [ 7] This is just for testing purposes

  lib/countless/rake_tasks.rb:
    * [ 3] This is just for testing purposes here. Keep it exactly like that.

  spec/fixtures/files/test/test_spec.rb:
    * [29] Do something
  ```
  * **notes:optimize**, **notes:fixme**, **notes:todo**, **notes:testme**,
    **notes:deprecateme** (by default, see `config.annotation_tags`, to
    configure more defaults)
  * **notes:custom**: Show notes for custom annotation (run via `bundle exec
    rake notes:custom ANNOTATION='NOTE'`)

### Addtional Configuration

```ruby
# All the configured values here represent the Gem defaults.
Countless.configure do |config|
  # The base/root path of the project to work on. This path is used as a #
  # prefix to all relative path/file configurations. By default we check for a
  # Rake invokation (Rakefile location), a Rails invokation (project root) or
  # fallback the the current working directory of the process.
  config.base_path = Dir.pwd

  # The path to the cloc (https://github.com/AlDanial/cloc) utility. The gem
  # comes with a bundled version of the utility, ready to be used. But you
  # can also change the used binary path in order to use a different version
  # which you manually provisioned.
  config.cloc_path = File.expand_path('../../bin/cloc', __dir__)

  # We allow to configure additional file extensions to consider for
  # statistics calculation. They will be included in the default list. This
  # way you can easily extend the list.
  config.additional_stats_file_extensions = []

  # All the file extensions to consider for statistics calculation
  config.stats_file_extensions = %w[
    rb js jsx ts tsx css scss coffee rake erb haml h c cpp rs
  ] + config.additional_stats_file_extensions

  # We allow to configure additional application object types. They will be
  # included in the default list. This way you can easily extend the list.
  config.additional_stats_app_object_types = []

  # Configure the application (in the root +app+ directory) object types,
  # they will be added as regular directories as well as their testing
  # counter parts (minitest/RSpec)
  config.stats_app_object_types = %w[
    channels consumers controllers dashboards decorators fields helpers jobs
    mailboxes mailers models policies serializers services uploaders
    validators value_objects views
  ] + config.additional_stats_app_object_types

  # We allow to configure additional statistics directories. They will be
  # included in the default list. This way you can easily extend the list.
  config.additional_stats_directories = []

  # A list of custom base directories in an application / gem
  config.stats_base_directories = [
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
  ] + config.additional_stats_directories

  # We allow to configure additional detailed statistics patterns. They will
  # be included in the default list. This way you can easily extend the list.
  config.additional_detailed_stats_patterns = {}

  # All the detailed statistics (class/method and tests/examples) patterns
  # which will be used for parsing the source files to gather the metrics
  config.detailed_stats_patterns = {
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
  }.deep_merge(config.additional_detailed_stats_patterns)

  # We allow to configure additional annotation directories. They will be
  # included in the default list. This way you can easily extend the list.
  config.additional_annotations_directories = []

  # Configure the directories which should be checked for annotations
  config.annotations_directories = %w[
    app config db src lib test tests spec doc docs
  ] + config.additional_annotations_directories

  # We allow to configure additional annotation files/patterns. They will be
  # included in the default list. This way you can easily extend the list.
  config.additional_annotations_files = []

  # Configure the files/patterns which should be checked for annotations
  config.annotations_files = %w[
    Appraisals CHANGELOG.md CODE_OF_CONDUCT.md config.ru docker-compose.yml
    Dockerfile Envfile Gemfile *.gemspec Makefile Rakefile README.md
  ] + config.additional_annotations_files

  # We allow to configure additional annotation tags. They will be included
  # in the default list. This way you can easily extend the list.
  config.additional_annotation_tags = []

  # Configure the annotation tags which will be search
  config.annotation_tags = %w[
    OPTIMIZE FIXME TODO TESTME DEPRECATEME
  ] + config.additional_annotation_tags

  # We allow to configure additional annotation patterns. They will be
  # included in the default list. This way you can easily extend the list.
  config.additional_annotation_patterns = {}

  # Configure all known file extensions of annotations files
  config.annotation_patterns = {
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
  }.deep_merge(config.additional_annotation_patterns)
end
```

## Development

After checking out the repo, run `make install` to install dependencies. Then,
run `make test` to run the tests. You can also run `make shell-irb` for an
interactive prompt that will allow you to experiment.

## Code of Conduct

Everyone interacting in the project codebase, issue tracker, chat
rooms and mailing lists is expected to follow the [code of
conduct](./CODE_OF_CONDUCT.md).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/hausgold/countless. Make sure that every pull request adds
a bullet point to the [changelog](./CHANGELOG.md) file with a reference to the
actual pull request.

## Releasing

The release process of this Gem is fully automated. You just need to open the
Github Actions [Release
Workflow](https://github.com/hausgold/countless/actions/workflows/release.yml)
and trigger a new run via the **Run workflow** button. Insert the new version
number (check the [changelog](./CHANGELOG.md) first for the latest release) and
you're done.
