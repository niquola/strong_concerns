# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'strong_concerns/version'

Gem::Specification.new do |spec|
  spec.name          = "strong_concerns"
  spec.version       = StrongConcerns::VERSION
  spec.authors       = ["niquola"]
  spec.email         = ["niquola@gmail.com"]
  spec.description   = %q{Gem **strong_concerns** is technically helping you to create concerns in a right way, minimizing and making explicit interface between object and concern.}
  spec.summary       = %q{Gem **strong_concerns** is technically helping you to create concerns in a right way, minimizing and making explicit interface between object and concern.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
