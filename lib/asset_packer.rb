require File.join(File.dirname(__FILE__), 'palmade/asset_packager')

if defined?(USE_RAILS) && USE_RAILS
  Palmade::AssetPackager::RailsPackager.new(Dir.pwd).run(ARGV)
end