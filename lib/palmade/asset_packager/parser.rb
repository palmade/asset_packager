require 'erb'
require 'yaml'

# typical structure of an asset_pakages.yml file
# 1st level - package name
# 2nd level - asset type
# 3rd level - asset files (may contain option parameters)

module Palmade::AssetPackager::Parser
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
  
  # build the package list and update the internal sources attribute
  def build_package_list(src_name, dir = false)
    logger.info("** Parsing package list #{src_name} (dir: #{dir ? 'true' : 'false' })")

    yml_data = dir ? read_dir(src_name) : read_yml(src_name)
    yml_data.keys.each do |package_name|
      sources[package_name] ||= { }
      build_package_asset_list(package_name, yml_data[package_name])
    end
    
    post_parse
  end

  protected
    def post_parse
      sources.keys.each do |package_name|
        sp = sources[package_name]
        sp.keys.each do |asset_type|
          sp[asset_type].post_parse
        end
      end
    end

    def build_package_asset_list(package_name, pdata)
      sp = sources[package_name]

      # asset types can be javascripts, stylesheets, images
      pdata.keys.each do |asset_type|
        klass = get_asset_type_class(asset_type)
        unless klass.nil?
          sp[asset_type] ||= klass.new(self, package_name, asset_root, logger)
          sp[asset_type].update(pdata[asset_type])
        end
      end
    end
end

Palmade::AssetPackager::Base.send(:include, Palmade::AssetPackager::Parser)
