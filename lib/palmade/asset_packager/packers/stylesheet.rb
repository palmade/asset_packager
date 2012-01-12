module Palmade::AssetPackager::Packers
  class Stylesheet
    class << self
      def concatenate(sources, options={})
        sources.collect { |source|
          self.new.read(source, options)
        }.join("\n\n")
      end

      def pack(source)
        self.new.minify(source)
      end
    end

    # read CSS file, parsing import statements
    def read(filename, options={})
      relative_dir = File.dirname(filename)
      partial      = File.read(filename)
      public_root  = options.fetch(:public_root) { Palmade::AssetPackager.configuration.public_root }

      partial.split(/[\n\r]/).collect do |line|
        if asset_url = parse_asset_url(line) and not stylesheet_import?(line)
          asset_dir = File.expand_path(File.dirname(asset_url), relative_dir)
          asset     = File.basename(asset_url)
          line.sub!(asset_url, File.join(calculate_asset_path(asset_dir),
                                         asset))
        elsif stylesheet_import?(line)
          import_url = parse_asset_url(line)

          import_absolute_path =
            import_url =~ /^[\/].+/ ? File.join(public_root, import_url) : File.expand_path(import_url, relative_dir)

          line = read(import_absolute_path) + "\n"
        end

        line.strip
      end.join("\n")
    end

    def minify(source)
      source.gsub!(/\s+/, " ")           # collapse space
      source.gsub!(/\/\*(.*?)\*\/ /, "") # remove comments - caution, might want to remove this if using css hacks
      source.gsub!(/\} /, "}\n")         # add line breaks
      source.gsub!(/\n$/, "")            # remove last break
      source.gsub!(/ \{ /, " {")         # trim inside brackets
                        source.gsub!(/; \}/, "}")          # trim inside brackets
                        source
    end

    private
    ##
    # Calculates the path to the asset after the stylesheet
    # has been moved to the package_path
    #
    def calculate_asset_path(asset_dir)
      package_path       = Palmade::AssetPackager.configuration.package_path

      asset_dir          = Pathname.new(asset_dir) unless asset_dir.is_a?(Pathname)
      dummy_package_path = File.join(package_path, 'asset_type_here')
      dummy_package_path = Pathname.new(dummy_package_path)

      asset_dir.relative_path_from(dummy_package_path).to_s
    end

    def stylesheet_import?(line)
      line =~ /^\@import\s+url\(\s*[\"\'](.+)[\"\']\s*\).*/ or
        line =~ /^\@import\s+url\(\s*([^\"\']+\s*)\).*/
    end

    def parse_asset_url(line)
      line =~ /url\(\s*[\"\']([^\/].+)[\"\']\s*\)/ or
        line =~ /url\(\s*([^\/][^\"\']+)\s*\)/ or
        line =~ /^\@import\s+url\(\s*[\"\'](.+)[\"\']\s*\).*/ or
        line =~ /^\@import\s+url\(\s*([^\"\']+\s*)\).*/

      $1 rescue nil
    end
  end
end
