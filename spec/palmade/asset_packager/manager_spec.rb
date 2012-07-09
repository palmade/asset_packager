require 'spec_helper'

module Palmade::AssetPackager
  describe Manager do
    let(:configuration) do
      configuration = { :public_root         => public_root,
                        :package_dir         => package_dir,
                        :minify_assets?      => false,
                        :deflate_assets?     => false,
                        :package_assets?     => false,
                        :base                => assets_fixture[:base],
                        :signin              => assets_fixture[:signin],
                        :leading_whitespace  => assets_fixture[:leading_whitespace],
                        :trailing_whitespace => assets_fixture[:trailing_whitespace]
                      }
      configuration.stub(:public_root)   { public_root }
      configuration.stub(:package_dir)   { package_dir }
      configuration.stub(:package_assets?) { false }
      configuration.stub(:deflate_assets?) { false }
      configuration
    end

    let(:no_package) { '/javascripts/no_package.js' }

    before do
      Palmade::AssetPackager.stub(:configuration) { configuration }
    end

    describe "#asset_include" do
      context "add package using hash format" do
        it "should add given asset" do
          subject.asset_include :javascripts, :package => 'signin'
        end
      end

      context "add package using string format" do
        it "should add given asset" do
          subject.asset_include :javascripts, 'package:base'
        end
      end

      context "add single asset" do
        it "should add given asset" do
          subject.asset_include :javascripts, 'no_package'
        end
      end

      context "asset doesn't exist" do
        it "should log an error"
      end
    end

    describe "#get_assets" do
      context "multiple assets included in one #asset_include" do
        before do
          subject.asset_include :javascripts,
                                      'package:base',
                                      'package:signin',
                                      'no_package',
                                      'package: leading_whitespace',
                                      'package:trailing_whitespace '
        end

        let(:all_assets) do
          assets = []
          assets.concat(url_assets_fixture(:signin)[:javascripts])
          assets.concat(url_assets_fixture(:base)[:javascripts])
          assets.concat([no_package]).uniq
          assets.concat(url_assets_fixture(:leading_whitespace)[:javascripts])
          assets.concat(url_assets_fixture(:trailing_whitespace)[:javascripts])
        end

        it "should get all included assets" do
          subject.get_assets(:javascripts).should include *all_assets
        end
      end

      context "absolute path to asset" do
        before do
          subject.asset_include :javascripts, '/absolute/asset.js'
        end

        it "should include the asset" do
          subject.get_assets(:javascripts).should include '/absolute/asset.js'
        end

        it "should not prepend the asset type to the path" do
          subject.get_assets(:javascripts).first.should eql '/absolute/asset.js'
        end
      end


      context "assets were included via #asset_include" do
        before do
          subject.asset_include :javascripts, :package => 'signin'
          subject.asset_include :javascripts, 'package:base', :set => 'top'
          subject.asset_include :javascripts, 'no_package'
          subject.asset_include :javascripts, 'doesnt_exists.js'
        end

        let(:all_assets) do
          assets = []
          assets.concat(url_assets_fixture(:signin)[:javascripts])
          assets.concat(url_assets_fixture(:base)[:javascripts])
          assets.concat([no_package]).uniq
        end

        it "should get all included assets" do
          subject.get_assets(:javascripts).should include *all_assets
        end

        it "should list them in the order that they were included" do
          subject.get_assets(:javascripts).should eql all_assets
        end

        it "should not include non-existent asset files" do
          subject.get_assets(:javascripts).should_not include '/javascripts/doesnt_exists.js'
        end

        context "multiple #get_assets calls," do
          it "should list an asset only once" do
            subject.get_assets(:javascripts).should include *all_assets
            subject.get_assets(:javascripts).should be_empty
          end

          context "get assets for a package then get all other assets" do
            it "should not include the package assets for the second call" do
              signin_assets = subject.get_assets(:javascripts, :package => 'signin')
              subject.get_assets(:javascripts).should_not include *signin_assets
            end
          end

          context "get assets for a set, then get all other assets" do
            it "should not include the single asset for the second call" do
              top_assets = subject.get_assets(:javascripts, :set => 'top')
              subject.get_assets(:javascripts).should_not include *top_assets
            end
          end
        end

        context "package assets enabled" do
          before do
            configuration[:package_assets?] = true
            configuration.stub(:package_assets?) { true }
          end

          it "should return the url for the packed package asset" do
            assets = subject.get_assets(:javascripts)
            assets.should include '/assets/javascripts/signin.js'
            assets.should include '/assets/javascripts/base.js'
          end

          it "should not include the individual urls for the package" do
            assets = subject.get_assets(:javascripts)
            assets.should_not include url_assets_fixture(:signin)
            assets.should_not include url_assets_fixture(:base)
          end

          context "deflate assets enabled" do
            before do
              configuration[:deflate_assets?] = true
              configuration.stub(:deflate_assets?) { true }
            end

            it "should return the url for the deflated package asset" do
              assets = subject.get_assets(:javascripts)
              assets.should include '/assets/javascripts/signin.js.z'
              assets.should include '/assets/javascripts/base.js.z'
            end

            it "should not do anything to the non-package asset files" do
              subject.get_assets(:javascripts).should include no_package
            end
          end

          it "should not do anything to the non-package asset files" do
            subject.get_assets(:javascripts).should include no_package
          end
        end

        context "parent controller has assets of its own" do
          it "should include parent's assets"
          it "should list parent's assets in the chain first"
          it "should include its own assets"
        end

        context "a given `package` is specified" do
          context "symbol format" do
            it "should only return the assets for the given package" do
              assets = subject.get_assets(:javascripts, :package => :signin)
              assets.should eql url_assets_fixture(:signin)[:javascripts]
            end
          end

          context "string format" do
            it "should only return the assets for the given package" do
              assets = subject.get_assets(:javascripts, :package => 'signin')
              assets.should eql url_assets_fixture(:signin)[:javascripts]
            end
          end
        end

        context "a given `set` is specified" do
          it "should only return the assets for the given set" do
            assets = subject.get_assets(:javascripts, :set => :top)
            assets.should eql url_assets_fixture(:base)[:javascripts]
          end
        end
      end

      context "no assets were included via asset_include" do
        it "should not return any assets" do
          subject.get_assets(:javascripts, :package => :base).should be_empty
          subject.get_assets(:javascripts, :set => :top).should be_empty
          subject.get_assets(:javascripts).should be_empty
          subject.get_assets(:stylesheets).should be_empty
        end
      end
    end
  end
end
