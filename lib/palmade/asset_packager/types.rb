module Palmade::AssetPackager
  module Types
    autoload :Abstract, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/types/abstract')
    autoload :Javascript, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/types/javascript')
    autoload :Stylesheet, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/types/stylesheet')
    autoload :Image, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/types/image')

    def self.get_asset_type_class(asset_type)
      const_get(asset_type)
    end
  end
end
