require 'zlib'

module Palmade::AssetPackager
  class Packager
    attr_reader :packages

    def initialize(options={})
      @logger   = options.fetch(:logger) { Palmade::AssetPackager.logger }

      @packages =
        initialize_packages options.fetch(:packages)
    end

    def packemall(options={})
      @logger.info "Nothing to pack" and return if @packages.empty?

      @logger.info "Packing packages..."

      @packages.each do |name, package|
        output_dir =
          options.fetch(:package_path) {
            Palmade::AssetPackager.configuration.package_path }

        compatibility_mode = Palmade::AssetPackager.configuration.compatibility_mode

        package.assets.keys.each do |type|
          final_output_dir =
            if compatibility_mode
              compat_output_dir(output_dir, type, name)
            else
              output_dir
            end

          cache(name, type, package.packit(type), final_output_dir)
        end
      end

      @logger.info "Packing done"
    end

    def cache(package, type, contents, output_dir)
      @logger.info "Nothing to cache" and return if @packages.empty?

      compatibility_mode = Palmade::AssetPackager.configuration.compatibility_mode

      output_dir = File.join(output_dir, type.to_s) unless compatibility_mode

      FileUtils.mkdir_p(output_dir) unless File.exists?(output_dir)

      filename = File.join(output_dir,
                           packages[package].filename(type))

      File.open(filename, 'wb+') {|f| f.write(contents) }

      File.open("#{filename}.z", 'wb+') do |f|
        zd = Zlib::Deflate.new(Zlib::BEST_COMPRESSION, 15, Zlib::MAX_MEM_LEVEL)
        # output raw deflate
        f << zd.deflate(contents, Zlib::FINISH)[2..-5]
        zd.close
      end
    end

    private

    def initialize_packages(config)
      packages = config.select do |key, value|
        is_package_hash? value and @logger.debug "Package hash for #{key} found"
      end

      packages.each.inject({}) do |packages, package|
        packages[package[0]] = Palmade::AssetPackager::Package.new(package[0], self, package[1])
        packages
      end
    end

    def is_package_hash?(hash)
      return false unless hash.is_a?(Hash)
      return (hash.include?(:javascripts) or hash.include?(:stylesheets))
    end

    def compat_output_dir(output_dir, type, package_name)
      package_dir = Palmade::AssetPackager.configuration.package_dir

      File.expand_path(File.join(output_dir, '..', type.to_s, package_dir.to_s, package_name.to_s))
    end
  end
end
