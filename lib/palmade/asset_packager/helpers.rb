module Palmade::AssetPackager
  module Helpers
    autoload :RailsHelper, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/helpers/rails_helper')
    autoload :MerbHelper, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/helpers/merb_helper')
  end
end
