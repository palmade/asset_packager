require 'yaml'

module Palmade::AssetPackager
  class Configuration < Hash

    def initialize(params = {})
      @logger  = params.fetch(:logger) { Palmade::AssetPackager.logger }

      self[:asset_root]     = default_asset_root
      self[:package_dir]    = default_package_dir
      self[:public_root]    = default_public_root
      self[:package_path]   = default_package_path
      self[:asset_version]  = default_asset_version
      self[:asset_sources]  = []
      self[:deflate_assets] = false
      self[:minify_assets]  = false
      self[:package_assets] = false
    end

    def method_missing(sym, *args, &block)
      if sym.to_s =~ /(.+)=$/
        self[$1] = args.first
      elsif keys.include? sym
        self[sym]
      else
        super
      end
    end

    def respond_to?(sym, include_private = false)
      keys.include?(sym) || super
    end

    def load_configuration(options={})
      self[:asset_root]  = options.fetch(:asset_root)  { default_asset_root }
      reload_asset_root_dependents

      config_file = options.fetch(:config_file) { default_config_file }
      config_dir  = options.fetch(:config_dir)  { default_config_dir }

      load_options_from_configuration_files(config_file, config_dir)

      load_options(options)
    end

    def deflate_assets?
      self[:deflate_assets]
    end

    def minify_assets?
      self[:minify_assets]
    end

    def package_assets?
      self[:package_assets]
    end

    private

    def reload_asset_root_dependents
      self[:public_root]  = default_public_root
      self[:package_path] = default_package_path
    end

    def load_options_from_configuration_files(config_file, config_dir)
      conf_file = load_configuration_file(config_file) || {}
      conf_dir  = load_configuration_dir(config_dir)   || {}

      conf = conf_file.merge(conf_dir)

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

    def load_options(options={})
      return unless options

      merge!(options)
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
      File.join(self[:asset_root], 'config', 'asset_packager.yml')
    end

    def default_config_dir
      File.join(self[:asset_root], 'config', 'asset_packages')
    end

    def default_public_root
      File.expand_path(ENV['ASSET_PUBLIC_ROOT'] || File.join(self[:asset_root], 'public'))
    end

    def default_package_path
      File.join(self[:public_root], self[:package_dir])
    end

    def default_package_dir
      'assets'
    end

  end
end
