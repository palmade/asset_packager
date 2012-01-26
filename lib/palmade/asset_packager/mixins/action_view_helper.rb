module Palmade::AssetPackager
  module Mixins::ActionViewHelper

    def javascript_tags(options = { })
      asset_tags('javascripts', options)
    end

    def stylesheet_tags(options = { })
      asset_tags('stylesheets', options)
    end

    protected

    def asset_tags(asset_type, options)
      options[:deflate_assets] = asset_deflate_ok?

      assets = spider_am(asset_type, options)

      assets.collect do |asset|
        render_asset(asset_type, asset)
      end.join("\n") unless assets.nil? or assets.empty?
    end

    private

    def render_asset(asset_type, as)
      case asset_type
      when 'javascripts'
        javascript_include_tag(as)
      when 'stylesheets'
        stylesheet_link_tag(as)
      end
    end

    def spider_am(asset_type, asset_options = { })
      # only get the instance asset_manager, to set the rendered flag properly
      # the commented version above, is not thread-safe!!!
      asset_manager.nil? ? [ ] :
        asset_manager.get_assets(asset_type,
                                 Palmade::AssetPackager::Utils.symbolize_keys(asset_options))
    end

    # WATCH OUT!!!
    # the following are overrides, and may not work with Rails version, later than 1.2.3
    def compute_public_path(source, dir = nil, ext = nil, options = { })
      controller.compute_public_path(source, dir, ext, options)
    end

    def compute_asset_host(source)
      controller.compute_asset_host(source)
    end

    def rails_asset_id(source)
      controller.rails_asset_id(source)
    end

  end
end
