module Palmade::AssetPackager
  module Mixins::ActionControllerInstanceHelper

    def self.included(base)
      base.class_eval do
        hide_action :asset_manager, :javascript_include, :stylesheet_include, :asset_deflate_ok?,
          :asset_include, :asset_managers, :compute_public_path,
          :compute_asset_host, :compute_rails_asset_id

        helper_method :asset_manager, :asset_managers, :javascript_include, :stylesheet_include, :asset_deflate_ok?
      end
    end

    def asset_manager(create_if_needed = false)
      if defined?(@asset_manager)
        @asset_manager
      elsif create_if_needed
        (@asset_manager = Palmade::AssetPackager::Manager.new).tap do |am|
          am.parents = self.class.asset_managers
        end
      else
        self.class.asset_manager
      end
    end

    def asset_managers
      asset_managers = [ ]
      asset_managers << @asset_manager if defined?(@asset_manager) && !@asset_manager.nil?
      asset_managers += self.class.asset_managers
      asset_managers
    end

    def javascript_include(*sources)
      asset_include('javascripts', *sources)
    end

    def stylesheet_include(*sources)
      asset_include('stylesheets', *sources)
    end

    def asset_deflate_ok?
      request.env.include?('HTTP_ACCEPT_ENCODING') and \
        request.env['HTTP_ACCEPT_ENCODING'].split(/\s*\,\s*/).include?('deflate')
    end

    def asset_include(asset_type, *sources)
      am = asset_manager(true)
      unless am.nil?
        self.class.asset_include_to_am(am, asset_type, *sources)
      end
    end

    def compute_public_path(source, dir = nil, ext = nil, options = { })
      options = Palmade::AssetPackager::Utils.stringify_keys(options)
      options['use_asset_host'] = true unless options.include?('use_asset_host')

      source += ".#{ext}" if !ext.nil? && File.extname(source).blank?
      unless source =~ %r{^[-a-z]+://}
        source = "/#{dir}/#{source}" unless dir.nil? || source[0] == ?/

        asset_id = compute_rails_asset_id(source)
        source += '?' + asset_id unless asset_id.blank?

        if request.nil?
          rur = nil
        elsif request.respond_to?(:relative_url_root)
          rur = request.relative_url_root
        else
          rur = ActionController::Base.relative_url_root
        end

        unless rur.nil? || rur.empty? || ActionController::Base.asset_skip_relative_url_root
          source = File.join(rur, source)
        end

        if options['use_asset_host']
          source = File.join(compute_asset_host(source), source)
        end
      end
      source
    end

    def compute_asset_host(source)
      asset_version = self.class.asset_version || 0
      if host = self.class.asset_host
        host % [ (source.hash % 4), asset_version ]
      else
        nil
      end
    end

    def compute_rails_asset_id(source)
      ENV["RAILS_ASSET_ID"] ||
        File.mtime("#{RAILS_ROOT}/public/#{source}").to_i.to_s rescue ""
    end

  end
end
