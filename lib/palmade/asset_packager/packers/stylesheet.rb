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

      partial.split(/[\n\r]/).collect do |line|
        line = convert_uris(line, relative_dir)
        line = convert_imports(line, relative_dir)

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
      compatibility_mode = Palmade::AssetPackager.configuration.compatibility_mode
      package_path       = Palmade::AssetPackager.configuration.package_path

      asset_dir          = Pathname.new(asset_dir) unless asset_dir.is_a?(Pathname)
      dummy_package_path = File.join(package_path, 'asset_type_here')

      dummy_package_path = File.join(dummy_package_path, 'foo') if compatibility_mode

      dummy_package_path = Pathname.new(dummy_package_path)

      asset_dir.relative_path_from(dummy_package_path).to_s
    end

    def convert_uris(css, relative_dir)
      css.gsub(/url\(("([^"]*)"|'([^']*)'|([^)]*))\)/im) do
        uri = $1.to_s
        uri.gsub!(/["']+/, '')
        # Don't process URLs that are already absolute
        unless uri =~ /^[a-z]+\:\/\//i
          asset_dir = File.expand_path(File.dirname(uri), relative_dir)
          asset     = File.basename(uri)
          uri       = File.join(calculate_asset_path(asset_dir), asset)
        end
        "url('#{uri.to_s}')"
      end
    end

    def convert_imports(css, relative_dir)
      package_path       = File.join(Palmade::AssetPackager.configuration.package_path, 'foo')

      css.gsub(/@import\s+url\(("([^"]*)"|'([^']*)'|([^)]*))\)/im) do
        uri = $1.to_s
        uri.gsub!(/["']+/, '')

        # Recalculate absolute path to asset url
        import_path = File.expand_path(uri, package_path)
        "\n" + read(import_path) + "\n"
      end

    end

  end
end
