module Palmade::AssetPackager
  module Helpers
    autoload :RailsHelper, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/helpers/rails_helper')
    autoload :Rails2Helper, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/helpers/rails2_helper')

    def self.use(helper_name, *args)
      mod = const_get(helper_name)
      if args.size > 0
        mod.setup(*args)
      else
        mod
      end
    end
  end
end
