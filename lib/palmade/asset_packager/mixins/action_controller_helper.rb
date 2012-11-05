module Palmade::AssetPackager
  module Mixins::ActionControllerHelper
    def asset_manager(su = false, create_if_needed = false)
      if su
        superclass.asset_manager
      else
        if defined?(@asset_manager)
          @asset_manager
        elsif create_if_needed
          @asset_manager = Palmade::AssetPackager::Manager.new
        elsif self == ActionController::Base
          nil
        else
          superclass.asset_manager
        end
      end
    end

    def asset_managers
      asset_managers = [ ]
      asset_managers << @asset_manager if defined?(@asset_manager) && !@asset_manager.nil?
      if self != ActionController::Base
        asset_managers += superclass.asset_managers
      end

      asset_managers
    end

    def javascript_include(*sources)
      asset_include('javascripts', *sources)
    end

    def stylesheet_include(*sources)
      asset_include('stylesheets', *sources)
    end

    def before_filter_javascript(*sources)
      before_filter { |cont| cont.javascript_include(*sources) }
    end

    def before_filter_stylesheet(*sources)
      before_filter { |cont| cont.stylesheet_include(*sources) }
    end

    def asset_include(asset_type, *sources)
      am = asset_manager(false, true)
      unless am.nil?
        asset_include_to_am(am, asset_type, *sources)
      end
    end

    def asset_include_to_am(am, asset_type, *sources)
      am.asset_include(asset_type, *sources)
    end

    def prevent_default_assets!(val = true)
      self.prevent_default_assets = val
    end

    def prevent_default_assets?
      not self.prevent_default_assets.nil?
    end

  end
end
