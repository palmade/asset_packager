module Palmade::AssetPackager::Types
  class Javascript < Abstract
    def asset_type
      'javascripts'
    end

    def asset_extension
      'js'
    end

    def build
      logger.debug("Creating combined version (#{target_filename})")

      FileUtils.mkpath(File.dirname(target_filename))
      File.open(target_filename, "w") do |f|
        assets.each do |a|
          partial = case a.source
            when String
              build_asset(a.source, a.options)
            when Array
              a.source.collect { |as| build_asset(as, a.options) }.join("\n\n")
          end

          f.write(partial)
          f.write("\n\n")
        end
      end

      logger.debug("Creating deflated version (#{target_filename_z})")
      deflate(File.read(target_filename), target_filename_z)
    end

    protected
      def build_asset(a, options = [ ])
        logger.debug("Processing asset: #{a}")

        asset_filename = find_asset(a)
        raise AssetFileNotFound, "Asset file not found (#{a})" if asset_filename.nil?

        if options.include?('no_min')
          logger.debug("...  parsing as raw file")
          File.read(asset_filename)
        else
          logger.debug("...  js minifying file")
          Palmade::AssetPackager::Jsmin.minify(File.read(asset_filename) + "\n\n")
        end
      end
  end
end
