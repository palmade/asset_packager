require 'erb'
require 'yaml'

# typical structure of an asset_pakages.yml file
# 1st level - package name
# 2nd level - asset type
# 3rd level - asset files (may contain option parameters)

module Palmade::AssetPackager::Parser  
  # build the package list and update the internal sources attribute
  def build_package_list(src_name, dir = false)
    logger.info("** Parsing package list #{src_name} (dir: #{dir ? 'true' : 'false' })")
    
    yml_data = dir ? read_dir(src_name) : read_yml(src_name)
    yml_data.keys.each do |package_name|
      build_package_asset_list(package_name, yml_data[package_name])
    end
    
    post_parse
  end

  protected
  
  # read a directory of asset_packages.yml files
  def read_dir(dname)
    output = { }
    Dir.glob(File.join(dname, '**', '*.yml')).each { |p| output.update(read_yml(p)) }
    output
  end
  
  # read a single asset_packages.yml file
  def read_yml(fname)
    YAML.load(ERB.new(IO.read(fname)).result)
  end
  
  def post_parse
    sources.values.each { |am| am.post_parse }
  end
  
  def build_package_asset_list(package_name, pdata)
    sp = sources[package_name]
    if sp.nil?
      sp = Palmade::AssetPackager::Manager.new(self, package_name, asset_root, logger)
      sources[package_name] = sp
    end
    
    sp.update_assets_from_yml(pdata)
  end
end
