# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "criteria_7_and_10/version"

Gem::Specification.new do |s|
  s.name        = "criteria_7_and_10"
  s.version     = Criteria7And10::VERSION
  s.authors     = ["Gallagher Polyn"]
  s.email       = ["gallagher.polyn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{HUD-92264-A Criterion 7 and Criterion 10}
  s.description = %q{Criterion 7 and 10 share most behavior -- the former is for purchases, the latter for refinances.}

  s.rubyforge_project = "criteria_7_and_10"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency("rspec", "= 2.6.0")
  # s.add_dependency('activesupport', "= 3.1.0")
  # s.add_dependency('activemodel', "= 3.1.0")
end
