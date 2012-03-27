module Palmade::AssetPackager
  module Mixins

    autoload :ActionControllerHelper, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/mixins/action_controller_helper')
    autoload :ActionControllerInstanceHelper, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/mixins/action_controller_instance_helper')
    autoload :ActionViewHelper, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/mixins/action_view_helper')
    autoload :CellsHelper, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/mixins/cells_helper')
    autoload :LegacyCompatibility, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/mixins/legacy_compatibility')

  end
end
