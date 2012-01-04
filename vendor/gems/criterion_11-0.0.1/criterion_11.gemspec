# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "criterion_11/version"

Gem::Specification.new do |s|
  s.name        = "criterion_11"
  s.version     = Criterion11::VERSION
  s.authors     = ["Gallagher Polyn"]
  s.email       = ["gallagher.polyn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{HUD-92264-A Criterion 11}
  s.description = %q{HUD-92264-A Criterion 11 - loan amount based on grant(s), loan(s), tax credit(s) or gift(s)}

  s.rubyforge_project = "criterion_11"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_dependency('activemodel', "= 3.1.0")
  s.add_dependency('activesupport', "= 3.1.0")
  s.add_dependency('criterion_7')
  s.add_dependency('criterion_10')
  # s.add_runtime_dependency "rest-client"
end
