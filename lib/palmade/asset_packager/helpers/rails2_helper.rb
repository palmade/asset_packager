module Palmade::AssetPackager
  module Helpers::Rails2Helper
    CONFIGURATOR_FILE_PATH = "config/configurations/asset_packager.rb"

    def self.setup(configuration)
      add_configuration_options(configuration)
      load_configurator

      add_extensions(configuration)

      rp = Palmade::AssetPackager::RailsPackager.new(configuration.root_path)
      rp.run("rails_attach")

      unless configuration.action_controller.asset_version.nil?
        ActionController::Base.asset_version = configuration.action_controller.asset_version
      end

      unless configuration.action_controller.asset_host.nil?
        ActionController::Base.asset_host = configuration.action_controller.asset_host
      end
    end

    def self.load_configurator(configurator = CONFIGURATOR_FILE_PATH)
      configurator = Rails.root.join(configurator).to_s
      config       = Rails.configuration

      if File.exists?(configurator)
        Rails.configuration.instance_eval do
          eval(IO.read(configurator), binding, configurator)
        end
      end
    end

    protected

    def self.add_extensions(configuration)
      if configuration.frameworks.include?(:action_controller) &&
        configuration.frameworks.include?(:action_view)

        ActionController::Base.send(:extend, Mixins::ActionControllerHelper)
        ActionController::Base.send(:include, Mixins::ActionControllerInstanceHelper)
        ActionView::Base.send(:include, Mixins::ActionViewHelper)

        # include cell extensions
        configuration.after_initialize do
          if defined?(Palmade::Cells)
            Palmade::Cells::Base.send(:include, Mixins::CellsHelper)
          end
        end
      end
    end

    def self.add_configuration_options(configuration)
      if configuration.frameworks.include?(:action_controller)
        class << ActionController::Base
          cattr_accessor :asset_version
          cattr_accessor :asset_skip_relative_url_root
          self.asset_version = 0
          self.asset_skip_relative_url_root = false
        end
      end
    end

  end
end
