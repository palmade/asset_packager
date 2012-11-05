module Palmade::AssetPackager
  class Manager
    attr_reader   :assets
    attr_accessor :parents

    def initialize
      @assets          = {}
      @packager        = Palmade::AssetPackager.packager
      @parents         = nil
      @rendered_assets = []
    end

    def asset_include(type, *assets)
      options = assets.length == 1 ? {} : Utils.extract_options!(assets)

      type    = type.to_sym

      @assets[type] ||= []

      assets.each do |asset|
        @assets[type] << Palmade::AssetPackager::Asset.new(asset, options)
      end

      @assets[type]
    end

    ##
    # Get all assets that were included via asset_include.
    #
    # Valid options are:
    # [:package]    Only get assets for the given package
    # [:set]        Only get assets for the specified set
    #
    def get_assets(type, options = {})
      type = type.to_sym

      filtered_assets = []

      parents.each do |parent|
        filtered_assets.concat(parent.assets[type]) if parent.assets.include? type
      end if parents

      filtered_assets.concat(@assets[type]) if @assets.include?(type)

      return [] if filtered_assets.nil? or filtered_assets.empty?

      if package_name = options[:package]
        filtered_assets = filter_by_package_name(package_name.to_sym,
                                                 filtered_assets)
      end

      if set = options[:set]
        filtered_assets = filter_by_set(set.to_sym, filtered_assets)
      end

      # Get asset paths and remove duplicates
      filtered_assets = filtered_assets.map do |asset|
        asset.paths(type)
      end.flatten.uniq

      # Remove already rendered assets (paths)
      (filtered_assets - @rendered_assets).tap do |assets|
        @rendered_assets.concat(assets)
      end
    end

    private

    def filter_by_package_name(name, assets)
      assets.select do |asset|
        asset.package? and asset.name == name
      end
    end

    def filter_by_set(set, assets)
      assets.select do |asset|
        asset.set? and asset.set == set
      end
    end
  end
end
