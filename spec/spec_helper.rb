require 'rubygems'
require 'bundler/setup'
require 'logger'

require 'palmade/asset_packager'

Dir["./spec/support/**/*.rb"].each {|f| require f}

module Helpers
  def rspec_root
    File.dirname(__FILE__)
  end

  def fixtures_root
    File.join(rspec_root, 'fixtures')
  end

  def public_root
    File.join(fixtures_root, 'public')
  end

  def package_dir
    'assets'
  end

  def assets_fixture
    @assets_fixture ||= {
      :base   => {
        :javascripts => ['base_1.js', 'base_2.js', 'jquery.js'],
        :stylesheets => ['style.css', 'awesome.css']
      },
      :signin => {
        :javascripts => ['a*.js',
                         'jquery.js',
                         'jquery.js',
                         'doesnt_exist.js',
                         '/absolute/package.js']
      }
    }
  end

  def abs_assets_fixture(name)
    assets_fixture[name.to_sym].inject({}) do |abs_assets, (type, assets)|
      abs_assets[type] = assets.collect do |asset|
          File.join(public_root, type.to_s, asset)
        end
      abs_assets
    end
  end
end

RSpec.configure do |config|
  config.before { Palmade::AssetPackager.logger = Logger.new('/dev/null') }
  config.include Helpers
end
