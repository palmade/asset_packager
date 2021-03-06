require 'logger'
require 'fileutils'
require 'erb'

ASSET_PACKAGER_LIB_PALMADE_DIR = File.dirname(__FILE__)
ASSET_PACKAGER_LIB_DIR = File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, '..')
ASSET_PACKAGER_ROOT_DIR = File.join(ASSET_PACKAGER_LIB_DIR, '..')

module Palmade
  module AssetPackager
    autoload :Runner,        File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/runner')
    autoload :Asset,         File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/asset')
    autoload :Bundler,       File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/bundler')
    autoload :Configuration, File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/configuration')
    autoload :Deployer,      File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/deployer')
    autoload :Helpers,       File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/helpers')
    autoload :Manager,       File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/manager')
    autoload :Mixins,        File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/mixins')
    autoload :Packers,       File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/packers')
    autoload :Package,       File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/package')
    autoload :Packager,      File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/packager')
    autoload :Utils,         File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/utils')
    autoload :VERSION,       File.join(ASSET_PACKAGER_LIB_PALMADE_DIR, 'asset_packager/version')

    class << self
      attr_accessor :configuration
      attr_writer   :logger
    end

    def self.logger
      @logger ||= create_logger
    end

    def self.boot!(options = {})
      self.logger.level = Logger::DEBUG if options[:debug]

      @configuration = Configuration.new
      @configuration.load_configuration(options)
    end

    private
    def self.create_logger
      Logger.new($stdout).tap do |logger|
        logger.level = Logger::INFO
      end
    end

    def self.packager
      Thread.current[:asset_packager] ||= Packager.new(
                                            :packages => self.configuration)
    end

    def self.package!(options={})
      packager.packemall(options)
    end

    def self.bundle(options={})
      bundler = AssetPackager::Bundler.new(options)
      bundler.bundle
    end

    def self.deploy(options={}, apps=nil)
      deployer = AssetPackager::Deployer.new(options, apps)
      deployer.deploy
    end

  end
end
