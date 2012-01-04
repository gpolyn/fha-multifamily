# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "criterion_10/version"

Gem::Specification.new do |s|
  s.name        = "criterion_10"
  s.version     = Criterion10::VERSION
  s.authors     = ["Gallagher Polyn"]
  s.email       = ["gallagher.polyn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{HUD-92264-A Criterion 10}
  s.description = %q{Criterion 10 gives the HUD loan amount based on existing indebtedness, repairs, and loan closing charges for multifamily and healthcare properties}

  s.rubyforge_project = "criterion_10"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency("rspec", "= 2.6.0")
  s.add_dependency('criteria_7_and_10')
  # s.add_runtime_dependency "rest-client"
end
