# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "integration_test_redis/version"

Gem::Specification.new do |s|
  s.name        = "integration_test_redis"
  s.version     = IntegrationTestRedis::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brendon Murphy"]
  s.email       = ["xternal1+github@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Redis integration test server}
  s.description = %q{Control a non-persistent Redis server for use in integration tests.}

  s.rubyforge_project = "integration_test_redis"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "redis"
  s.add_development_dependency "rspec"
end
