module Palmade::AssetPackager
  class Manager
    attr_accessor :logger
    attr_accessor :assets

    ASSET_TYPE_MAP =  {
      'javascripts' => [ :Javascript, 'js' ],
      'stylesheets' => [ :Stylesheet, 'css' ],
      'images' => [ :Image, 'png' ]
    }

    def initialize(base, name, asset_root, logger)
      @ap = base
      @package_name = name
      @asset_root = asset_root
      @logger = logger
      @assets = { }
    end

    def [](asset_type)
      @assets[asset_type]
    end

    def find_assets(asset_type, asset_options)
      case
      when asset_options.include?('package')
        apt = @ap.find_package(asset_options['package'], asset_type)
        unless apt.nil?
          apt.find_assets(asset_options)
        end
      else
        unless @assets[asset_type].nil?
          @assets[asset_type].find_assets(asset_options)
        end
      end
    end

    def inherit_assets(other_ams, dup = false)
      other_ams = [ other_ams ] unless other_ams.is_a?(Array)
      other_ams.each do |other_am|
        other_am.assets.each do |asset_type, asset|
          my_asset = get_or_create_asset(asset_type)
          my_asset.include_assets(asset, dup) unless asset.nil?
        end
      end
    end

    def update_assets_from_yml(pdata)
      # asset types can be javascripts, stylesheets, images
      pdata.keys.each do |asset_type|
        pdata[asset_type].each do |sl|
          case sl
          when Hash
            update_options(asset_type, sl)
          when String
            update_asset(asset_type, sl)
          end
        end
      end
    end

    def update_options(asset_type, opts)
      apt = get_or_create_asset(asset_type)
      apt.update_options(opts)
    end

    def update_asset(asset_type, source, source_options = { })
      apt = get_or_create_asset(asset_type)
      apt.update_asset(source, source_options)
    end

    def post_parse
      @assets.values.each { |apt| apt.post_parse }
    end

    def build_package
      @assets.values.each do |apt|
        logger.info("=> Asset type: #{@package_name}.#{apt.asset_type}")
        apt.build
      end
    end

    def destroy_package
      @assets.values.each do |apt|
        apt.destroy
      end
    end

    protected

    def get_or_create_asset(asset_type)
      if @assets[asset_type].nil?
        klass = Palmade::AssetPackager::Types.get_asset_type_class(ASSET_TYPE_MAP[asset_type.to_s][0])
        @assets[asset_type] = klass.new(@ap, @package_name, @asset_root, @logger) unless klass.nil?
      else
        @assets[asset_type]
      end
    end
  end
end
