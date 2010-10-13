module Palmade::AssetPackager::Types
  class Stylesheet < Abstract
    def asset_type
      'stylesheets'
    end

    def asset_extension
      'css'
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

        css_content = css_read_file(asset_filename)

        if options.include?('no_min')
          logger.debug("...  parsing as raw file")
          css_content
        else
          logger.debug("...  css minifying file")
          css_minify(css_content)
        end
      end

      # read CSS file, parsing import statements
      def css_read_file(asset_filename, copy_assets = true, first_call = true)
        relative_dir = File.dirname(asset_filename)
        partial = File.read(asset_filename)

        partial = partial.split(/[\n\r]/).each { |ln|
          asset_url = nil
          if ln =~ /url\(\s*[\"\']([^\/].+)[\"\']\s*\)/ ||
              ln =~ /url\(\s*([^\/][^\"\']+)\s*\)/
            asset_url = $~[1]
          end

          if asset_url
            asset_absolute_path = asset_url =~ /^[\/].+/ ? File.join(asset_root, asset_url) : File.expand_path(asset_url, relative_dir)
            dest_asset = File.join(target_path, File.basename(asset_absolute_path))

            if File.file?(asset_absolute_path)
              css_copy_asset_file(asset_absolute_path, dest_asset)

              ln.gsub!(/url\(\s*[\"\']([^\/].+)[\"\']\s*\)/, "url(\"#{File.basename(dest_asset)}\")")
              ln.gsub!(/url\(\s*([^\/][^\"\']+)\s*\)/, "url(\"#{File.basename(dest_asset)}\")")
            end
          end

          ln.strip
        }.join("\n")

        partial.split(/[\n\r]/).collect { |ln|
          if ln =~ /^\@import\s+url\(\s*[\"\'](.+)[\"\']\s*\).*/ ||
            ln =~ /^\@import\s+url\(\s*([^\"\']+\s*)\).*/
            import_url = $~[1]
            import_absolute_path = import_url =~ /^[\/].+/ ? File.join(asset_root, import_url) : File.expand_path(import_url, relative_dir)

            logger.debug("...  importing css file: #{import_absolute_path}")
            ln = css_read_file(import_absolute_path, copy_assets, false) + "\n"
          end

          ln.strip
        }.join("\n")
      end

      def css_copy_asset_file(asset_absolute_path, dest_asset)
        if File.exists?(dest_asset)
          if File.size(asset_absolute_path) != File.size(dest_asset)  ||
            File.mtime(asset_absolute_path) > File.mtime(dest_asset)

            logger.debug("...  copying asset file #{dest_asset}")
            FileUtils.copy(asset_absolute_path, dest_asset)
          else
            logger.debug("...  asset file #{dest_asset} still fresh")
          end
        else
          logger.debug("...  copying asset file #{dest_asset}")
          FileUtils.copy(asset_absolute_path, dest_asset)
        end
      end

      def css_minify(source)
        source.gsub!(/\s+/, " ")           # collapse space
        source.gsub!(/\/\*(.*?)\*\/ /, "") # remove comments - caution, might want to remove this if using css hacks
        source.gsub!(/\} /, "}\n")         # add line breaks
        source.gsub!(/\n$/, "")            # remove last break
        source.gsub!(/ \{ /, " {")         # trim inside brackets
        source.gsub!(/; \}/, "}")          # trim inside brackets
        source
      end
  end
end
