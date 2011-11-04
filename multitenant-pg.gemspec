# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "multitenant/version"

Gem::Specification.new do |s|
  s.name        = "multitenant-pg"
  s.version     = Multitenant::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Fabio Kuhn"]
  s.email       = ["mordaroso@gmail.com"]
  s.homepage    = "http://github.com/mordaroso/multitenant-pg"
  s.summary     = %q{scope database queries to current tenant}
  s.description = %q{Rails multitenancy with PostgreSQL schemas.}

  s.add_dependency(%q<activerecord>, ['>= 3.1'])
  s.add_development_dependency(%q<pg>, ["~> 0.11.0"])
  s.add_development_dependency(%q<rspec>, ['~> 2.7.0'])
  s.add_development_dependency(%q<rspec-core>, ['~> 2.7.0'])
  s.add_development_dependency(%q<rspec-mocks>, ['~> 2.7.0'])
  s.add_development_dependency(%q<database_cleaner>, ['>= 0.5.0'])
  s.add_development_dependency(%q<rake>, ['>= 0.8.7'])

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
