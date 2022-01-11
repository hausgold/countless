![Countless](doc/assets/project.svg)

[![Continuous Integration](https://github.com/hausgold/countless/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/hausgold/countless/actions/workflows/test.yml)
[![Gem Version](https://badge.fury.io/rb/countless.svg)](https://badge.fury.io/rb/countless)
[![Test Coverage](https://automate-api.hausgold.de/v1/coverage_reports/countless/coverage.svg)](https://knowledge.hausgold.de/coverage)
[![Test Ratio](https://automate-api.hausgold.de/v1/coverage_reports/countless/ratio.svg)](https://knowledge.hausgold.de/coverage)
[![API docs](https://automate-api.hausgold.de/v1/coverage_reports/countless/documentation.svg)](https://www.rubydoc.info/gems/countless)

This is a reusable collection of helpers which provide tools for code
statistics and annotations. The origin of the source is extracted from Rails
and is extended in configurability.

- [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
- [Contributing](#contributing)

## Installation

Add this line to your gemspec:

```ruby
spec.add_runtime_dependency 'countless'
```

And then execute:

```bash
$ bundle
```

## Usage

@TODO: Write some docs here.

## Development

After checking out the repo, run `make install` to install dependencies. Then,
run `make test` to run the tests. You can also run `make shell-irb` for an
interactive prompt that will allow you to experiment.

To release a new version, update the version number in `version.rb`, and then
run `make release`, which will create a git tag for the version, push git
commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/hausgold/countless.
