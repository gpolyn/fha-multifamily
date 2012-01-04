# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fha_utilities/version"

Gem::Specification.new do |s|
  s.name        = "fha_utilities"
  s.version     = FhaUtilities::VERSION
  s.authors     = ["Gallagher Polyn"]
  s.email       = ["gallagher.polyn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Items common to many FHA multifamily and healthcare loan programs}
  s.description = %q{Items common to many FHA multifamily and healthcare loan programs}

  s.rubyforge_project = "fha_utilities"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_dependency('activemodel', "= 3.1.0")
  s.add_dependency('activesupport', "= 3.1.0")
  # s.add_runtime_dependency "rest-client"
end
