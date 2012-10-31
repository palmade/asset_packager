require 'pathname'

module Palmade::AssetPackager
  class Deployer
    def initialize(options, apps = nil)
      @logger  = options.fetch(:logger) { Palmade::AssetPackager.logger }
      @options = options.tap do |o|
        o.delete(:config_file)
      end

      # Apps to bundle
      @apps    = (apps.nil? or apps.empty?) ? get_apps : apps
    end

    def deploy
      bundle_apps(@apps)
    end

    protected

    def get_apps_root
      Palmade::AssetPackager.configuration.apps_root
    end

    ##
    # Gets apps that are in config. Not necessarily the apps to bundle.
    #
    def get_apps
      Palmade::AssetPackager.configuration.apps
    end

    ##
    # Returns the path to the application by concatenating
    # apps_root and app_name.
    #
    # If the path is given in the configuration file and it is
    # absolute, then it is returned; If not, it is taken to be
    # relative to the apps_root
    #
    def get_abs_path(app_name)
      app = get_apps.find do |app|
        (app == app_name or app.include? app_name.to_sym) rescue false
      end

      app_path =
        if app.respond_to?(:values)
          app.values.first
        else
          app_name
        end

      app_path = Pathname.new(app_path)

      app_path.absolute? ?
        app_path :
        File.expand_path(File.join(get_apps_root, app_path))
    end

    def get_app_name(app_name)
      if app_name.respond_to?(:keys)
        app_name.keys.first
      else
        app_name
      end
    end

    def bundle_apps(apps)
      @logger.info "Bundling apps"

      apps.each do |app|
        app_path = get_abs_path(app)
        app_name = get_app_name(app)

        unless File.exists?(app_path)
          @logger.error { "#{app_path} not found!" }
          next
        end

        @logger.debug "Bundling #{app_name}"

        if bundler = fork
          Process.wait2(bundler)
        else
          options = {
            :asset_root => app_path,
            :target_dir => File.expand_path('.')
          }.merge(@options)

          new_configuration = Configuration.new
          new_configuration.load_configuration(options)

          Palmade::AssetPackager.configuration = new_configuration
          Thread.current[:asset_packager] = Packager.new(:packages => new_configuration)

          Palmade::AssetPackager.bundle(options)

          break
        end
      end
    end

  end
end
