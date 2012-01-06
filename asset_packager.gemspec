# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'asset_packager'
  s.version     = '0.6'
  s.authors     = ['Palmade']
  s.summary     = 'An asset_packager for use with Rails and other frameworks'
  s.description = 'An asset_packager for use with Rails and other frameworks'

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = 'rails_packer'
  s.require_paths    = ['lib']
  s.extra_rdoc_files = ['README', 'CHANGELOG', 'COPYING', 'LICENSE']
  s.rdoc_options     = ['--line-numbers', '--inline-source', '--title', 'asset_packager', '--main', 'README']

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
end
