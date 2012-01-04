# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sec_223f_refinance/version"

Gem::Specification.new do |s|
  s.name        = "sec_223f_refinance"
  s.version     = Sec223fRefinance::VERSION
  s.authors     = ["Gallagher Polyn"]
  s.email       = ["gallagher.polyn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{HUD FHA Section 223(f) Refinance Loan}
  s.description = %q{HUD FHA Section 223(f) Refinance Loan}

  s.rubyforge_project = "sec_223f_refinance"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency("rspec", "= 2.6.0")
  s.add_dependency('criterion_10')
  s.add_dependency('criterion_11')
  s.add_dependency('sec_223f_common_behavior')
  s.add_dependency('fha_utilities')
  s.add_dependency('sec223f_cash_requirement')
end
