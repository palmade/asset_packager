require 'delegate'
require 'pathname'

module Palmade::AssetPackager
  class Asset < SimpleDelegator
    ASSET_EXTENSIONS = {:javascripts => 'js',
                        :stylesheets => 'css'}

    attr_reader :name
    attr_reader :package
    attr_reader :set

    alias :package? :package
    alias :set?     :set

    def initialize(obj, options)
      super obj

      @packager    = Palmade::AssetPackager.packager
      @public_root = Palmade::AssetPackager.configuration.public_root
      @package     = false
      @name        = nil
      @set         = options.fetch(:set) { nil }
      @set         = @set.to_sym if @set
      @logger      = Palmade::AssetPackager.logger

      initialize_asset options
    end

    def paths(type, options = {})
      type = type.to_sym

      package? ? super : Array(path(type, options))
    end

    private
    ##
    # Gets the path for the given asset
    #
    def path(type, options = {})
      abs_path =
        Pathname.new(@name).absolute? ?
        @name :
        File.join('/', type.to_s,
                  "#{@name}")

      abs_path = add_extension_if_needed(abs_path, type)
      exists?(abs_path) ? abs_path : ((warn_missing name unless @set == :default) and nil)
    end

    def warn_missing(name)
      @logger.warn("Asset not found: #{name}")
    end


    def initialize_asset(options)
      case __getobj__
      when Hash, /^package:\s*(\w+)\s*$/
        package_name  = ($1 or self[:package]).to_sym

        @package      = true
        @name         = package_name

        __setobj__ @packager.packages[package_name]

      when String, Symbol
        @package = false
        @name    = self.to_s
      end
    end

    def exists?(asset)
      File.exists? File.join(@public_root, asset)
    end

    def extension_for(type)
      ASSET_EXTENSIONS[type.to_sym]
    end

    def add_extension_if_needed(file, type)
      File.extname(file).empty? ? "#{file}.#{ASSET_EXTENSIONS[type]}" :
                                  file
    end
  end
end
