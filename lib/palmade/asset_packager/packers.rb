module Palmade::AssetPackager
  module Packers
    autoload :Javascript, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/packers/javascript')
    autoload :Stylesheet, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/packers/stylesheet')
  end
end
