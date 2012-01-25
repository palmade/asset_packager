module Palmade::AssetPackager
  module Mixins::ActionControllerHelper

    def self.extended(base)
      base.class_eval do
        cattr_accessor :rails_asset_packager
        class_inheritable_accessor :default_assets
        self.default_assets = {}
      end

      class << base
        alias_method_chain :process, :asset_packager
      end
    end

    def asset_manager(su = false, create_if_needed = false)
      if su
        superclass.asset_manager
      else
        if defined?(@asset_manager)
          @asset_manager
        elsif create_if_needed
          unless rails_asset_packager.nil?
            @asset_manager = rails_asset_packager.create_am(self)
          end
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

    def process_with_asset_packager(*args)
      asset_before_process_hook(*args)
      process_without_asset_packager(*args)
    end

    private

    # class-level process hook (should only be parsed once / per class load)
    def asset_before_process_hook(*args)
      unless defined?(@processed_default_assets) && @processed_default_assets
        [ 'stylesheets', 'javascripts' ].each do |asset_type|
          asset_controller = 'controllers/' + controller_path
          if rails_asset_packager.asset_exists?(asset_type, asset_controller)
            default_assets[asset_type] ||= [ ]
            default_assets[asset_type] << asset_controller
          end
        end
        @processed_default_assets = true
      end
    end

  end
end
