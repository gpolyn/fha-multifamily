# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sec223f_cash_requirement/version"

Gem::Specification.new do |s|
  s.name        = "sec223f_cash_requirement"
  s.version     = Sec223fCashRequirement::VERSION
  s.authors     = ["Gallagher Polyn"]
  s.email       = ["gallagher.polyn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Sec 223(f) cash requirement functionality}
  s.description = %q{Sec 223(f) cash requirement functionality}

  s.rubyforge_project = "sec223f_cash_requirement"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_dependency('hud_92264')
  s.add_dependency('hud_92013')
  # s.add_runtime_dependency "rest-client"
end
