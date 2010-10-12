require 'rubygems'
gem 'echoe'
require 'echoe'

Echoe.new("asset_packager") do |p|
  p.author = "palmade"
  p.project = "palmade"
  p.summary = "An asset_packager for use with Rails and other frameworks"

  p.need_tar_gz = false
  p.need_tgz = true

  p.clean_pattern += ["pkg", "lib/*.bundle", "*.gem", ".config"]
  p.rdoc_pattern = ['README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc']
end

gem 'rspec'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.spec_opts.push("-f s")
end

task :default => [ :test, :spec ]
