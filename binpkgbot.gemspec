# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'binpkgbot/version'

Gem::Specification.new do |spec|
  spec.name          = "binpkgbot"
  spec.version       = Binpkgbot::VERSION
  spec.authors       = ["Sorah Fukumori"]
  spec.email         = ["her@sorah.jp"]

  spec.summary       = %q{Your robot to build Gentoo binpkgs in clean environment, continously}
  spec.homepage      = "https://github.com/sorah/binpkgbot"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
