module Palmade::AssetPackager
  module BasePackage

    def find_package(package_name, asset_type = nil)
      sp = sources[package_name]
      asset_type.nil? ? sp : sp[asset_type] unless sp.nil?
    end

    protected

    def build_package(package_name)
      logger.info("** Package build: #{package_name}")

      sp = find_package(package_name)
      unless sp.nil?
        sp.build_package
      end
    end

    def destroy_package(package_name)
      sp = find_package(package_name)
      unless sp.nil?
        sp.destroy_package
      end
    end

  end
end
