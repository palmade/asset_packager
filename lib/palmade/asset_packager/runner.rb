require 'optparse'

module Palmade::AssetPackager
  class Runner
    def initialize(argv)
      @argv = argv

      @options = {}
      @logger  = Palmade::AssetPackager.logger

      parse!
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: packit [command] [options]"

        opts.separator ""
        opts.separator "Bundle options:"

        opts.on("-t", "--target DIR", "Bundle assets inside dir")               { |dir| @options[:target_dir]   = File.expand_path(dir) }

        opts.separator ""
        opts.separator "Config options:"

        opts.on("-a", "--asset_root DIR", "Change to dir before starting")               { |dir| @options[:asset_root]   = File.expand_path(dir) }
        opts.on("--asset_version VER", "The asset version to make")                      { |ver| @options[:config_dir]   = ver }
        opts.on("-c", "--config_file FILE", "Load options from config file")             { |file| @options[:config_file] = File.expand_path(file) }
        opts.on("-C", "--config_dir DIR", "Load options from config files inside dir")   { |dir| @options[:config_dir]   = File.expand_path(dir) }

        opts.separator ""
        opts.separator "Common options:"

        opts.on("-d", "--debug", "Turns on debug messages")                  { @options[:debug] = true }
        opts.on_tail("-h", "--help", "Show this message")                    { puts opts; exit }
        opts.on_tail('-v', '--version', "Show version")                      { puts "Asset Packager #{VERSION}"; exit }
      end
    end

    # Parse the options.
    def parse!
      parser.parse! @argv
      @command   = @argv.shift || 'build'
      @arguments = @argv
    end

    def run
      Palmade::AssetPackager.boot! @options

      case @command
      when 'build'
        Palmade::AssetPackager.package!
      when 'bundle'
        Palmade::AssetPackager.bundle @options
      else
        @logger.error "Invalid command: #{@command}"
      end
    end

  end
end
