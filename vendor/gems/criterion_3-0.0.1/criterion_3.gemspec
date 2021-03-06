# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "criterion_3/version"

Gem::Specification.new do |s|
  s.name        = "criterion_3"
  s.version     = Criterion3::VERSION
  s.authors     = ["Gallagher Polyn"]
  s.email       = ["gallagher.polyn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{HUD-92264-A Criterion 3}
  s.description = %q{Criterion 3 gives the HUD loan amount based on value (replacement cost) for multifamily and healthcare properties}

  s.rubyforge_project = "criterion_3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency("rspec", "= 2.7.0")
  s.add_development_dependency("rspec-rails", "= 2.7")
  # s.add_runtime_dependency "rest-client"
  s.add_dependency('activemodel', "= 3.1.0")
end
