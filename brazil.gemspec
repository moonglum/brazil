# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'brazil/version'

Gem::Specification.new do |spec|
  spec.name          = 'brazil'
  spec.version       = Brazil::VERSION
  spec.authors       = ['moonglum']
  spec.email         = ['moonglum@moonbeamlabs.com']
  spec.summary       = %q{A DSL for Ruby to build AQL queries for ArangoDB}
  spec.description   = %q{Build AQL (ArangoDB Query Language) with this Sequel and ActiveRecord inspired DSL.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'aql', '~> 0.0.3'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'ashikawa-core', '~> 0.10.0'
  spec.add_development_dependency 'rspec', '~> 3.0.0.beta2'
end
