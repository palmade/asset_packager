require 'logger'
require 'fileutils'

ASSET_PACKAGER_LIB_PALMADE_DIR = File.dirname(__FILE__)
ASSET_PACKAGER_LIB_DIR = File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, '..')
ASSET_PACKAGER_ROOT_DIR = File.join(ASSET_PACKAGER_LIB_DIR, '..')

module Palmade
  module AssetPackager
    autoload :AssetBase,     File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/asset_base')
    autoload :Configuration, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/configuration')
    autoload :Jsmin,         File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/jsmin')
    autoload :Types,         File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/types')
    autoload :Base,          File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/base')
    autoload :BasePackage,   File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/base_package')
    autoload :BaseParser,    File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/base_parser')
    autoload :Helpers,       File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/helpers')
    autoload :Manager,       File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/manager')
    autoload :Mixins,        File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/mixins')
    autoload :RailsPackager, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/rails_packager')
    autoload :Utils,         File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/utils')

    COMPILED       = 1
    COMPILED_Z     = 2

    def self.logger
      @logger ||= create_logger
    end

    def self.boot!(options ={})
      @configuration = Configuration.new(options)
      @configuration.load_configuration
    end

    private
    def self.create_logger
      logger = Logger.new($stdout)
      logger.level = Logger::INFO
      logger
    end
  end
end
