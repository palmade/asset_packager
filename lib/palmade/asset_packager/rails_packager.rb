module Palmade::AssetPackager
  class RailsPackager
    class Error < StandardError; end
    class ConfigNotFound < Error; end
    class UnknownCommand < Error; end

    attr_accessor :logger
    attr_reader :asset_packager

    def initialize(rails_root)
      @rails_root = rails_root
      @logger ||= PALMADE_DEFAULT_LOGGER
    end

    def default_conf_file
      File.join(@rails_root, 'config/asset_packages.yml')
    end

    def default_conf_dir
      File.join(@rails_root, 'config/asset_packages')
    end

    def build
      logger.info("** Start building asset files")
      @asset_packager.build
    end

    def rebuild
      delete
      build
    end

    def delete
      logger.info("** Start deleting built asset files")
      @asset_packager.delete
    end

    def run(argv)
      logger.debug("** Initialize AssetPackager::Base")
      @asset_packager = Palmade::AssetPackager::Base.new(@logger)
      @asset_packager.asset_root = File.join(@rails_root, 'public')

      if File.exists?(default_conf_file)
        @asset_packager.build_package_list(default_conf_file)
      elsif File.exists?(default_conf_dir)
        @asset_packager.build_package_list(default_conf_dir, true)
      end

      case (argv.is_a?(Array) ? argv[0] : argv)
      when 'build', nil
        build
      when 'rebuild'
        rebuild
      when 'delete'
        delete
      when 'rails_attach'
        rails_attach
      else
        raise UnknownCommand, "Unknown command (#{argv[0]})"
      end
    end

    def rails_attach
      if defined?(ActionController::Base)
        ActionController::Base.rails_asset_packager = self
      else
        raise Error, "ActionController::Base not loaded"
      end
    end

    def create_am(controller)
      Palmade::AssetPackager::Manager.new(asset_packager,
        controller.controller_path.gsub(/\//, '_'), asset_packager.asset_root, logger)
    end

    def create_instance_am(cont_obj)
      Palmade::AssetPackager::Manager.new(asset_packager,
        cont_obj.controller_path.gsub(/\//, '_') + '_instance', asset_packager.asset_root, logger)
    end

    def asset_exists?(asset_type, asset_path)
      asset_root_path = File.join(asset_packager.asset_root, asset_type)
      file_extension = Palmade::AssetPackager::Manager::ASSET_TYPE_MAP[asset_type.to_s][1]

      File.exists?(File.join(asset_root_path, asset_path + ".#{file_extension}")) ||
        File.exists?(File.join(asset_root_path, asset_path))
    end
  end
end
