module Palmade::AssetPackager
  class Deployer
    def initialize(options)
      @logger      = options.fetch(:logger) { Palmade::AssetPackager.logger }
    end

    def deploy
      apps_root = get_apps_root
      apps      = get_apps

      bundle_apps(apps_root, apps)
    end

    protected

    def get_apps_root
      Palmade::AssetPackager.configuration.apps_root
    end

    def get_apps
      Palmade::AssetPackager.configuration.apps
    end

    def bundle_apps(apps_root, apps)
      apps.each do |app|
        app_path = File.expand_path(File.join(apps_root, app))

        next unless File.exists?(app_path)

        if bundler = fork
          Process.wait2(bundler)
        else
          options = {
            :asset_root => app_path,
            :target_dir => File.expand_path('.')
          }

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
