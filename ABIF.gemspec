# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ABIF/version'

Gem::Specification.new do |spec|
  spec.name          = "ABIF"
  spec.version       = ABIF::VERSION
  spec.authors       = ["Sascha Willuweit"]
  spec.email         = ["s@rprojekt.org"]
  spec.description   = %q{ABIF file format reader/parse/plotter.}
  spec.summary       = %q{Handle/Parse/Plot ABIF (Applied Biosystems Genetic Analysis Data File Format) FSA, AB1 and HID files.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
end
