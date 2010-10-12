require 'logger'
require 'fileutils'

ASSET_PACKAGER_LIB_PALMADE_DIR = File.dirname(__FILE__)
ASSET_PACKAGER_LIB_DIR = File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, '..')
ASSET_PACKAGER_ROOT_DIR = File.join(ASSET_PACKAGER_LIB_DIR, '..')

unless defined?(PALMADE_DEFAULT_LOGGER)
  PALMADE_DEFAULT_LOGGER = Logger.new($stdout)
  PALMADE_DEFAULT_LOGGER.level = Logger::INFO
end

module Palmade
  module AssetPackager
    autoload :AssetBase, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/asset_base')
    autoload :Jsmin, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/jsmin')
    autoload :Types, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/types')
    autoload :Base, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/base')
    autoload :BasePackage, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/base_package')
    autoload :BaseParser, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/base_parser')
    autoload :Helpers, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/helpers')
    autoload :Manager, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/manager')
    autoload :RailsPackager, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/rails_packager')

    COMPILED = 1
    COMPILED_Z = 2
  end
end
