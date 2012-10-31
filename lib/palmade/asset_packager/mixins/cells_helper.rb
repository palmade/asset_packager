module Palmade::AssetPackager
  module Mixins::CellsHelper

    def javascript_include(*sources)
      @controller.asset_include('javascripts', *sources)
    end

    def stylesheet_include(*sources)
      @controller.asset_include('stylesheets', *sources)
    end

  end
end
