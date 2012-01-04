# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sec_223f_common_behavior/version"

Gem::Specification.new do |s|
  s.name        = "sec_223f_common_behavior"
  s.version     = Sec223fCommonBehavior::VERSION
  s.authors     = ["Gallagher Polyn"]
  s.email       = ["gallagher.polyn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Behavior common to refinance and purchase Sec 223(f) loans}
  s.description = %q{Outputs the minimum of criteria 1, 3, 4 and 5}

  s.rubyforge_project = "sec_223f_common_behavior"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency("rspec", "= 2.6.0")
  s.add_dependency('criterion_3')
  s.add_dependency('criterion_4')
  s.add_dependency('criterion_5')
  s.add_dependency('activemodel', "= 3.1.0")
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
