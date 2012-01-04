# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sec223f_acquisition/version"

Gem::Specification.new do |s|
  s.name        = "sec223f_acquisition"
  s.version     = Sec223fAcquisition::VERSION
  s.authors     = ["Gallagher Polyn"]
  s.email       = ["gallagher.polyn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{HUD FHA Section 223(f) Acquisition Loan}
  s.description = %q{HUD FHA Section 223(f) Acquisition Loan}

  s.rubyforge_project = "sec223f_acquisition"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency("rspec", "= 2.6.0")
  s.add_dependency('criterion_7')
  s.add_dependency('hud_92013')
  s.add_dependency('criterion_11')
  s.add_dependency('sec223f_cash_requirement')
  s.add_dependency('sec_223f_common_behavior')
  s.add_dependency('fha_utilities')
  # s.add_runtime_dependency "rest-client"
end
