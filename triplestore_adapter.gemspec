# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.version            = File.read('VERSION').chomp
  spec.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  spec.name          = "triplestore_adapter"
  spec.authors       = ["Josh Gum"]
  spec.email         = ["josh.gum@oregonstate.edu"]

  spec.summary       = %q{A Triplestore/SPARQL adapter.}
  spec.description   = %q{Originally designed as a wrapper for blazegraph-rdf, but designed to make it easier to swap triplestore backends if necessary.}
  spec.homepage      = "https://github.com/osulp/TriplestoreAdapter"
  spec.license       = "MIT"

  spec.platform      = Gem::Platform::RUBY
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.has_rdoc      = false

  spec.required_ruby_version      = '>= 2.2.2'
  spec.requirements               = []

  spec.add_runtime_dependency     "rdf-blazegraph", "0.0.2"
  spec.add_runtime_dependency     "sparql-client", "~> 1.99"
  spec.add_runtime_dependency     "rdf-vocab", "~> 0.8.8"
  spec.add_runtime_dependency     "rdf", "~> 1.99"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "coveralls"
end
