# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hud_92013/version"

Gem::Specification.new do |s|
  s.name        = "hud_92013"
  s.version     = Hud92013::VERSION
  s.authors     = ["Gallagher Polyn"]
  s.email       = ["gallagher.polyn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{HUD-92013 form}
  s.description = %q{HUD-92013 form}

  s.rubyforge_project = "hud_92013"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
