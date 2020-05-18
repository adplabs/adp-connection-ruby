# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adp/connection/version'

Gem::Specification.new do |spec|
  spec.name          = "adp-connection"
  spec.version       = Adp::Connection::VERSION
  spec.authors       = ["ADP Marketplace"]
  spec.email         = ["richard.smith@adp.com"]
  # spec.owners        = ["ADP Marketplace, ADP Inc."]

  spec.summary       = %q{A library for Ruby that help applications connect to the ADP API Gateway.}
  spec.description   = %q{The ADP Client Connection Library is intended to simplify and aid the process of authenticating, authorizing and connecting to the ADP Marketplace API Gateway. The Library includes a sample application that can be run out-of-the-box to connect to the ADP Marketplace API **test** gateway.}
  spec.homepage      = "https://github.com/adplabs/adp-connection-ruby"
  spec.license       = "Apache-2.0"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # spec.add_dependency "uri"
  # spec.add_dependency "net/https"
  # spec.add_dependency "base64"
  spec.add_dependency "json", "~> 2.3"
  # spec.add_dependency 'securerandom'

  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
