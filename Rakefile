require 'rubygems'
gem 'echoe'
require 'echoe'

Echoe.new("asset_packager") do |p|
  p.author="Mark J"
  p.project = "palmade"
  p.summary = "An asset_packager for use with Rails and other frameworks"

  p.need_tar_gz = false
  p.need_tgz = true

  p.clean_pattern += ["pkg", "lib/*.bundle", "*.gem", ".config"]
  p.rdoc_pattern = ['README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc']
end
