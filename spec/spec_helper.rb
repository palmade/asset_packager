require 'rubygems'
require 'bundler/setup'
require 'logger'
require 'pathname'

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
        :javascripts => ['{base_1,base_2}.js', 'jquery.js'],
        :stylesheets => ['style.css', 'awesome.css']
      },
      :signin => {
        :javascripts => ['a*.js',
                         'jquery.js',
                         'jquery.js',
                         'doesnt_exist.js',
                         '/absolute/package.js']
      },
      :leading_whitespace => {
        :javascripts => ['leading_whitespace.js']
      },
      :trailing_whitespace => {
        :javascripts => ['trailing_whitespace.js']
      }
    }
  end

  def abs_assets_fixture(name)
    assets_fixture[name.to_sym].inject({}) do |abs_assets, (type, assets)|
      new_assets = assets.inject([]) do |new_assets, asset|
      abs_path = Pathname.new(asset).absolute? ?
        File.join(public_root, asset):
        File.join(public_root, type.to_s, asset)
        new_assets.concat(Dir.glob(abs_path))
      end

      abs_assets[type] = new_assets.uniq
      abs_assets
    end
  end

  def url_assets_fixture(name)
    abs_assets_fixture(name.to_sym).inject({}) do |url_assets, (type, assets)|
      url_assets[type] = assets.map do |asset|
        asset.sub(/^#{public_root}/, '')
      end.uniq

      url_assets
    end

  end
end

RSpec.configure do |config|
  config.before { Palmade::AssetPackager.logger = Logger.new('/dev/null') }
  config.include Helpers
end
