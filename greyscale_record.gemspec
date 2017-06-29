# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'greyscale_record/version'

Gem::Specification.new do |spec|
  spec.name          = "greyscale_record"
  spec.version       = GreyscaleRecord::VERSION
  spec.authors       = ["Greg Orlov"]
  spec.email         = ["gaorlov@gmail.com"]

  spec.summary       = "A light AcriveRecord like wrapper for a flat data interface, such as YAML files, or the Geyscale API"
  spec.description   = "An ActiveRecord-like interface for reading from & queryeing flat data interfaces"
  spec.homepage      = "https://github.com/greyscale-io/greyscale_record"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  spec.add_dependency "activesupport"
  spec.add_dependency "activemodel"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "m"

end
