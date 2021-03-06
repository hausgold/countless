# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'countless/version'

Gem::Specification.new do |spec|
  spec.name          = 'countless'
  spec.version       = Countless::VERSION
  spec.authors       = ['Hermann Mayer']
  spec.email         = ['hermann.mayer@hausgold.de']

  spec.summary       = 'Code statistics/annotations helpers'
  spec.description   = 'This gem includes reusable code statistics / ' \
                       'annotations helpers / Rake tasks.'

  spec.homepage      = 'https://github.com/hausgold/countless'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_runtime_dependency 'activesupport', '>= 5.2.0'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler', '>= 1.16', '< 3'
  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.24'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.7'
  spec.add_development_dependency 'simplecov', '< 0.18'
  spec.add_development_dependency 'yard', '~> 0.9.18'
  spec.add_development_dependency 'yard-activesupport-concern', '~> 0.0.1'
end
