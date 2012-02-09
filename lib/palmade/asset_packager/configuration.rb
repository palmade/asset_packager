module Palmade::AssetPackager
  class Configuration
    attr_reader :app_name
    attr_reader :asset_host
    attr_reader :asset_root
    attr_reader :asset_version
    attr_reader :deflate_assets
    attr_reader :minify_assets
    attr_reader :package_assets
    attr_reader :package_path
    attr_reader :package_dir
    attr_reader :public_root
    attr_reader :options

    alias :minify_assets?  :minify_assets
    alias :package_assets? :package_assets
    alias :deflate_assets? :deflate_assets

    def initialize(params = {})
      @asset_root     = default_asset_root
      @deflate_assets = true
      @minify_assets  = true
      @package_assets = true
      @package_dir    = default_package_dir
      @public_root    = default_public_root
      @package_path   = default_package_path
      @asset_version  = default_asset_version

      @logger         = params.fetch(:logger) { Palmade::AssetPackager::logger }

      @options        = {}
    end

    def load_configuration(options={})
      @asset_root = options.fetch(:asset_root)  { default_asset_root }

      config_file = options.fetch(:config_file) { default_config_file }
      config_dir  = options.fetch(:config_dir)  { default_config_dir }

      load_options_from_configuration_files(config_file, config_dir)

      load_options(options)
    end

    private

    def load_options_from_configuration_files(config_file, config_dir)
      conf_file = load_configuration_file(config_file)
      conf_dir  = load_configuration_dir(config_dir)

      conf =
        if conf_file and conf_dir
          conf_file.merge(conf_dir)
        elsif conf_file.nil? and conf_dir
          conf_dir
        else
          conf_file
        end

      load_options(conf)
    end

    def load_configuration_file(config_file)
      return unless valid_config_file? config_file

      @logger.info "Loading configuration file: #{config_file}"

      parse_configuration_file(config_file)
    end

    def load_configuration_dir(config_dir)
      return unless valid_config_dir? config_dir

      @logger.info "Loading configuration files inside #{config_dir}"

      config_files = Dir.glob(File.join(config_dir, '**', '*.yml')).sort

      config_files.map do |config_file|
        parse_configuration_file(config_file)
      end.inject(:merge)
    end

    ##
    # Sets known options. Unknown options are stored in @options
    #
    def load_options(options={})
      return unless options

      @app_name       = options[:app_name]       unless options[:app_name].nil?
      @asset_host     = options[:asset_host]     unless options[:asset_host].nil?
      @asset_version  = options[:asset_version]  unless options[:asset_version].nil?
      @deflate_assets = options[:deflate_assets] unless options[:deflate_assets].nil?
      @minify_assets  = options[:minify_assets]  unless options[:minify_assets].nil?
      @package_assets = options[:package_assets] unless options[:package_assets].nil?
      @package_dir    = options[:package_dir]    unless options[:package_dir].nil?
      @public_root    = options[:public_root]    unless options[:public_root].nil?

      @options.merge!(options)
    end

    def valid_config_file?(config_file)
      unless exists = File.exists?(config_file)
        @logger.warn "Given configuration file not found (#{config_file})"
      end
      exists
    end

    def valid_config_dir?(config_dir)
      unless exists = File.exists?(config_dir)
        @logger.warn "Given configuration directory doesn't exist (#{config_dir})"
      end

      if exists and not directory = File.directory?(config_dir)
        @logger.warn "Given configuration directory isn't really a directory (#{config_dir})"
      end

      exists and directory
    end

    def parse_configuration_file(config_file)
      @logger.debug "Parsing configuration file: #{config_file}"

      Utils.symbolize_keys(YAML.load(ERB.new(File.read(config_file)).result))
    end

    def default_asset_root
      File.expand_path(ENV['ASSET_ROOT'] || '.')
    end

    def default_asset_version
      '0'
    end

    def default_config_file
      File.join(asset_root, 'config', 'asset_packager.yml')
    end

    def default_config_dir
      File.join(asset_root, 'config', 'asset_packages')
    end

    def default_public_root
      File.expand_path(ENV['ASSET_PUBLIC_ROOT'] || File.join(asset_root, 'public'))
    end

    def default_package_path
      File.join(@public_root, @package_dir)
    end

    def default_package_dir
      'assets'
    end

  end
end
