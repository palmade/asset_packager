module Palmade::AssetPackager
  module Helpers::Rails2Helper
    def self.setup(configuration)
      add_configuration_options(configuration)
      add_extensions(configuration)
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
