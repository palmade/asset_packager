module Palmade::AssetPackager
  class Configuration
    attr_reader :asset_host
    attr_reader :asset_root
    attr_reader :asset_version
    attr_reader :deflate_assets
    attr_reader :minify_assets
    attr_reader :package_assets
    attr_reader :package_dir
    attr_reader :public_root
    attr_reader :others


    def initialize(options = {})
      @asset_root      = options.fetch(:asset_root) { default_asset_root }
      @deflate_assets  = true
      @minify_assets   = true
      @package_assets  = true
      @package_dir     = default_package_dir
      @public_root     = default_public_root

      @logger          = options.fetch(:logger) { Palmade::AssetPackager::logger }

      @others          = {}
    end

    def package_path
      @package_path ||= File.join(@public_root, @package_dir)
    end

    def load_configuration(config_file = default_config_file, config_dir = default_config_directory)
      conf = load_configuration_file(config_file)
      conf.merge!(load_configuration_dir(config_dir)) if File.exists? config_dir

      @asset_host     = conf.delete(:asset_host)     { nil }
      @asset_version  = conf.delete(:asset_version)  { nil }
      @deflate_assets = conf.delete(:deflate_assets) { true }
      @minify_assets  = conf.delete(:minify_assets)  { true }
      @package_assets = conf.delete(:package_assets) { true }
      @package_dir    = conf.delete(:package_dir)    { default_package_dir }
      @public_root    = conf.delete(:public_root)    { default_public_root }

      @others = conf
    end

    def load_configuration_file(config_file = default_config_file)
      @logger.info "Loading configuration file: #{config_file}"

      parse_configuration_file(config_file)
    end

    def load_configuration_dir(config_dir = default_config_directory)
      @logger.info "Loading configuration files inside #{config_dir}"

      config_files = Dir.glob(File.join(config_dir, '**', '*.yml')).sort

      config_files.map do |config_file|
        parse_configuration_file(config_file)
      end.inject(:merge)
    end

    private
    def parse_configuration_file(config_file)
      @logger.debug "Parsing configuration file: #{config_file}"

      unless File.exists?(config_file)
        @logger.warn "Configuration file, #{config_file}, not found"
        return {}
      end

      Utils.symbolize_keys(YAML.load(ERB.new(File.read(config_file)).result))
    end

    def default_asset_root
      File.expand_path(ENV['ASSET_ROOT'] || '.')
    end

    def default_config_file
      File.join(asset_root, 'config', 'asset_packager.yml')
    end

    def default_config_directory
      File.join(asset_root, 'config', 'asset_packages')
    end

    def default_public_root
      File.expand_path(ENV['ASSET_PUBLIC_ROOT'] || File.join(asset_root, 'public'))
    end

    def default_package_dir
      'assets'
    end

  end
end
