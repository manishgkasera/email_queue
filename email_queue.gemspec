# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'email_queue/version'

Gem::Specification.new do |spec|
  spec.name          = "email_queue"
  spec.version       = EmailQueue::VERSION
  spec.authors       = ["Manish Kasera"]
  spec.email         = ["manishgkasera@gmail.com"]
  spec.summary       = %q{High throughput email sending queue}
  spec.description   = %q{High throughput email sending queue}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "hirb"

  spec.add_dependency "activerecord"
  spec.add_dependency "mysql"
  spec.add_dependency "mail"
  spec.add_dependency "faker"
end
