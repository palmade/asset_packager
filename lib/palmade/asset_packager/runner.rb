require 'optparse'

module Palmade::AssetPackager
  class Runner
    def initialize(argv)
      @argv = argv

      @options = {}

      parse!
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: packit [options]"

        opts.separator ""
        opts.separator "Config options:"

        opts.on("-a", "--asset_root DIR", "Change to dir before starting")               { |dir| @options[:asset_root]   = File.expand_path(dir) }
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
      @command   = @argv.shift
      @arguments = @argv
    end

    def run
      Palmade::AssetPackager.boot! @options
      Palmade::AssetPackager.package!
    end

  end
end
