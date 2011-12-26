# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "karotz/version"

Gem::Specification.new do |s|
  s.name        = "karotz"
  s.version     = Karotz::VERSION
  s.authors     = ["Peter Schröder"]
  s.email       = ["phoetmail@googlemail.com"]
  s.homepage    = "http://github.com/phoet/karotz"
  s.description = s.summary     = %q{ruby bindings for karotz rest api}

  s.rubyforge_project = "karotz"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"

  s.add_runtime_dependency "httpclient"
  s.add_runtime_dependency "httpi"
  s.add_runtime_dependency "crack"

  s.add_runtime_dependency('jruby-openssl') if RUBY_PLATFORM == 'java'
end
