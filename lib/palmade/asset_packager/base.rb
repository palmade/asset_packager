module Palmade::AssetPackager
  class Base
    include Palmade::AssetPackager::BaseParser
    include Palmade::AssetPackager::BasePackage

    attr_accessor :logger
    attr_accessor :asset_root

    def initialize(logger)
      @logger ||= logger || Palmade::AssetPackager.logger
      @asset_root ||= Dir.pwd
    end

    def sources
      @sources ||= { }
    end
    
    def build
      sources.keys.each do |package|
        build_package(package)
      end
    end

    def delete
      sources.keys.each do |package|
        destroy_package(package)
      end
    end
  end
end
