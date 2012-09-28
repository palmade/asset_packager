module Palmade::AssetPackager
  class Bundler
    def initialize(options)
      @logger      = options.fetch(:logger) { Palmade::AssetPackager.logger }

      @target_dir  = options.fetch(:target_dir)         { default_target_dir  }

      @root        = calculate_root
    end

    def bundle
      return unless valid_target_dir?(@target_dir)

      create_root
      copy_asset_files
      deflate_asset_files

      package_dir = Palmade::AssetPackager.configuration.package_dir
      Palmade::AssetPackager.package!(:package_path => File.join(@root, package_dir))
    end

    protected

    def create_root(root = @root)
      if File.exists?(root)
        @logger.warn "Given bundle root exists, deleting!"
        FileUtils.rm_r(root)
      end

      @logger.info "Creating bundle root: #{root}"
      FileUtils.mkdir_p(root)
    end

    def deflate_asset_files(asset_sources = default_asset_sources)
      asset_sources.each do |source|
        pattern = File.join(configuration.asset_root, source, '**', '*{.css,.js}')
        Dir.glob(pattern).find_all { |f| File.size(f) >= 150 }
                         .each(&method(:deflate_asset_file))
      end

    end

    def copy_asset_files(asset_sources = default_asset_sources)
      asset_sources.concat(configuration.asset_sources)

      @logger.info "Copying the asset sources to the bundle root"

      asset_sources.each do |source|
        asset_type_dir = File.join(configuration.asset_root, source)

        unless valid_asset_type_dir? asset_type_dir
          @logger.warn "\t #{asset_type_dir} doesn't exist"

          next
        end

        @logger.debug "\tCopying #{source}"
        FileUtils.cp_r(asset_type_dir, @root)
      end
    end

    private

    def deflate_asset_file(path)
      File.open("#{path}.gz", 'wb+') do |f|
        zd = Zlib::Deflate.new(Zlib::BEST_COMPRESSION, 15, Zlib::MAX_MEM_LEVEL)
        # output raw deflate
        f << zd.deflate(IO.binread(path), Zlib::FINISH)[2..-5]
        zd.close
      end
    end

    def calculate_root
      @logger.error 'Please specify the app_name inside the configuration file(s)' unless configuration.app_name

      File.join(@target_dir,
                configuration.app_name,
                configuration.asset_version.to_s)
    end

    def valid_target_dir?(target_dir)
      if exists = File.exists?(target_dir)
        @logger.warn "Target dir already exists: #{target_dir}"

        unless directory = File.directory?(target_dir)
          @logger.error "Given target dir is not a directory! (#{target_dir})"
        end
      end

      !exists || (exists and directory)
    end

    def valid_asset_type_dir?(asset_type_dir)
      File.exists? asset_type_dir and File.directory? asset_type_dir
    end

    def default_asset_sources
      ['public/images', 'public/javascripts', 'public/stylesheets']
    end

    def default_target_dir
      File.join(configuration.asset_root, 'assets')
    end

    def configuration
      Palmade::AssetPackager.configuration
    end

  end
end
