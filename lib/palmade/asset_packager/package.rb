require 'forwardable'
require 'pathname'

module Palmade::AssetPackager
  class Package
    extend Forwardable

    ASSET_EXTENSIONS = {:javascripts => 'js',
                        :stylesheets => 'css'}

    def initialize(name, packager, options = {})
      @name     = name
      @logger   = options.delete(:logger) { Palmade::AssetPackager.logger }
      @assets   = initialize_assets(options)
      @packager = packager

      @dependencies_loaded = false
    end

    def assets
      load_dependencies

      @assets.inject({}) do |h, (k, v)|
        h[k] = v.flatten.uniq
        h
      end
    end

    def_delegator :assets, :[]

    def packit(type, options={})
      return nil unless @assets[type]

      minify_assets = Palmade::AssetPackager.configuration.minify_assets?

      load_dependencies

      @logger.info "\tPacking #{@name} #{type}"

      packer = get_packer(type)
      packed = packer.concatenate(@assets[type]) unless @assets[type].nil?
      packed = packer.pack(packed) if minify_assets

      packed
      packed << "\n\n"
    end

    def paths(type, options={})
      packed = options.fetch(:packed) { Palmade::AssetPackager.configuration.package_assets? }

      if packed
        return path_for type, options
      else
        return individual_asset_paths_for type
      end
    end

    def filename(type)
      File.join("#{@name}.#{ASSET_EXTENSIONS[type]}")
    end

    protected

    def individual_asset_paths_for(type)
      assets[type].map do |asset|
        asset.sub(path_to_url, '')
      end
    end

    def path_for(type, options={})
      options[:deflated] = options.fetch(:deflated) { Palmade::AssetPackager.configuration.deflate_assets? }

      url = File.join(Palmade::AssetPackager.configuration.package_dir,
                      type.to_s,
                      filename(type))

      url = "/#{url}" unless url =~ /^\//
      url << '.z' if options[:deflated]
      url
    end

    ##
    # Try to get packer for the given +type+.
    #
    # Makes certain assumptions for +type+:
    #
    # * +type+ is the lowercase version of the packer.
    # * +type+ is the `plural version of the packer.
    #
    # If +javascripts+ was passed as the +type+, then it will try to get
    # +Packers::Javascripts+, if that fails then it will try to get
    # +Packers::Javascript+.
    def get_packer(type)
      type = type.to_s.capitalize

      begin
        Palmade::AssetPackager::Packers.const_get(type)
      rescue NameError
        begin
          Palmade::AssetPackager::Packers.const_get(type[0..-2])
        rescue NameError
          raise "Packer for #{type} not found"
        end
      end
    end

    ##
    # Adds the asset file for the dependencies to
    # its own asset files. Does this only once.
    #
    def load_dependencies
      return if @dependencies_loaded

      @assets.each do |type, assets_type|
        assets_type.map! do |asset|
          asset.respond_to?(:call) ? asset.call : asset
        end
      end

      @dependencies_loaded = true
    end

    def dependencies
      @dependencies ||= {}
    end

    def add_dependencies(type, names)
      return unless names

      dependencies[type] ||= {}

      names.map!(&:to_sym)

      lambda do
        names.map(&:to_sym).map do |dep|
          @packager.packages[dep][type]
        end
      end
    end

    private

    def path_to_url
      /\A#{Regexp.escape(Palmade::AssetPackager.configuration.public_root)}/
    end

    def add_extension_if_needed(file, type)
      File.extname(file).empty? ? "#{file}.#{ASSET_EXTENSIONS[type]}" :
                                  file
    end

    ##
    # Parses raw assets_hash for @assets.
    #
    # Raw hashes are of the following format:
    # :type => ['foo.js', '/bar.js', {:include => 'another_package'}]
    #
    def initialize_assets(assets_hash)
      public_root = Palmade::AssetPackager.configuration.public_root

      a = {}
      assets_hash.each do |type, assets|
        assets.each do |asset|
          a[type] ||= []

          case asset
          when String
            # If path to asset is absolute, then assume that it is relative
            # to the public root e.g.
            # '/libwww/something.js' => 'public_root/libwww/something.js'
            # otherwise, assume that is stored inside
            # 'public_root/asset_type'
            abs_path = Pathname.new(asset).absolute? ?
              File.join(public_root, asset) :
              File.join(public_root, type.to_s, asset)

            abs_path = add_extension_if_needed(abs_path, type)

            found_assets = Dir.glob(abs_path)

            unless found_assets.empty?
              a[type] << Dir.glob(abs_path)
            else
              @logger.error "Asset file not found: (#{abs_path})"
            end
          when Hash
            a[type] << add_dependencies(type, asset[:include])
          end
        end

        @logger.debug "\tAdded #{a[type].count} #{type} for #{@name}" if a[type]
      end
      a
    end

  end
end

