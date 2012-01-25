module Palmade::AssetPackager
  module Mixins::ActionControllerInstanceHelper

    def self.included(base)
      base.class_eval do
        hide_action :asset_manager, :javascript_include, :stylesheet_include, :asset_deflate_ok?,
          :asset_in_production?, :asset_include, :asset_managers, :compute_public_path,
          :compute_asset_host, :compute_rails_asset_id

        helper_method :asset_manager, :asset_managers, :asset_in_production?, :asset_deflate_ok?, :javascript_include, :stylesheet_include

        if respond_to?(:before_render)
          before_render :asset_before_render_hook
        else
          def render_with_asset_hook(*params, &block)
            asset_before_render_hook(*params)
            render_without_asset_hook(*params, &block)
          end
          alias :render_without_asset_hook :render
          alias :render :render_with_asset_hook
        end
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
      if !asset_deflate_disabled? &&
        request.env.include?('HTTP_ACCEPT_ENCODING') &&
        request.env['HTTP_ACCEPT_ENCODING'].split(/\s*\,\s*/).include?('deflate')
        true
      else
        false
      end
    end

    def asset_in_production?
      ENV['ASSET_PACKAGER_FORCE_PRODUCTION'] || RAILS_ENV == "production"
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
      # TODO: Add support for multi-version asset hosts
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

    protected

    def prevent_default_assets?
      defined?(@asset_manager_prevent_defaults) && @asset_manager_prevent_defaults
    end

    def prevent_default_assets!(prevent = true)
      @asset_manager_prevent_defaults = prevent
    end

    def asset_deflate_disabled?
      (ENV.include?('ASSET_PACKAGER_DISABLE_DEFLATE_CHECKING') &&
      ENV['ASSET_PACKAGER_DISABLE_DEFLATE_CHECKING'] == '1')
    end

    private

    def asset_before_render_hook(*params)
      unless prevent_default_assets?
        unless defined?(@processed_default_assets) && @processed_default_assets
          # first, let's figure out if we're going to use layouts
          # the code that follows was copied from layouts.rb of the ActionController code
          layout = nil
          options = params.first

          if private_methods.include?('apply_layout?') || private_methods.include?(:apply_layout?)
            template_with_options = options.is_a?(Hash)
            if apply_layout?(template_with_options, options)
              layout = pick_layout(template_with_options, options, nil)
            end
          else
            extra_options = params[1] || {}
            if options.nil?
              options = { :template => default_template, :layout => true }
            elsif options == :update
              options = extra_options.merge({ :update => true })
            elsif options.is_a?(String) || options.is_a?(Symbol)
              case options.to_s.index('/')
              when 0
                extra_options[:file] = options
              when nil
                extra_options[:action] = options
              else
                extra_options[:template] = options
              end

              options = extra_options
            elsif !options.is_a?(Hash)
              extra_options[:partial] = options
              options = extra_options
            end

            layout_template = pick_layout(options)
            layout = layout_template.path_without_format_and_extension if layout_template
          end

          [ 'javascripts', 'stylesheets' ].each do |asset_type|
            # check for layout assets
            unless layout.nil?
              if rails_asset_packager.asset_exists?(asset_type, layout)
                asset_include(asset_type, layout, :set => 'default')
              end
            end

            # check for controller assets
            if self.class.default_assets[asset_type] && self.class.default_assets[asset_type].size > 0
              asset_include(asset_type, self.class.default_assets[asset_type], :set => 'default')
            end

            # check for action assets
            if rails_asset_packager.asset_exists?(asset_type, default_template_name)
              asset_include(asset_type, default_template_name, :set => 'default')
            end
          end

          @processed_default_assets = true
        end
      end

      true
    end

  end
end
