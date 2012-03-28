module Palmade::AssetPackager
  class Deployer
    def initialize(options, apps = nil)
      @logger  = options.fetch(:logger) { Palmade::AssetPackager.logger }
      @options = options.tap do |o|
        o.delete(:config_file)
      end

      @apps    = get_apps(apps)
    end

    def deploy
      apps_root = get_apps_root

      bundle_apps(apps_root, @apps)
    end

    protected

    def get_apps_root
      Palmade::AssetPackager.configuration.apps_root
    end

    def get_apps(apps = nil)
      (apps.nil? or apps.empty?) ?
        Palmade::AssetPackager.configuration.apps :
        apps
    end

    def bundle_apps(apps_root, apps)
      @logger.info "Bundling apps"

      apps.each do |app|
        app_path = File.expand_path(File.join(apps_root, app))

        unless File.exists?(app_path)
          @logger.error { "#{app_path} not found!" }
          next
        end

        @logger.debug "Bundling #{app}"

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
