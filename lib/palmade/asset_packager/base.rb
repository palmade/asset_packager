module Palmade; module AssetPackager; end; end

class Palmade::AssetPackager::Base
  attr_accessor :logger
  attr_accessor :asset_root

  def initialize(logger)
    @logger ||= logger || PALMADE_DEFAULT_LOGGER
    @asset_root ||= Dir.pwd
  end

  def sources
    @sources ||= { }
  end
  
  def build
    @sources.keys.each do |package|
      build_package(package)
    end
  end

  def delete
    @sources.keys.each do |package|
      delete_package(package)
    end
  end
end