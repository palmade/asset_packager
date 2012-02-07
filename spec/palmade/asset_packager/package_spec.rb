require 'spec_helper'

module Palmade::AssetPackager
  describe Package do
    let(:packager) { double(Packager) }
    let(:assets)   do
      assets_fixture[:signin]
    end
    subject { Package.new(:signin, assets, packager) }

    let(:configuration) do
      configuration = double(Configuration)
      configuration.stub(:public_root)     { public_root }
      configuration.stub(:package_dir)     { package_dir }
      configuration.stub(:minify_assets?)  { false }
      configuration.stub(:deflate_assets?) { false }
      configuration.stub(:package_assets?) { false }
      configuration
    end

    before do
      Palmade::AssetPackager.stub(:configuration) { configuration }
    end

    describe "#assets," do
      context "no asset type given," do
        it "should return all asset files" do
          subject.assets.should include :javascripts
        end
      end

      context "asset type exists," do
        let(:globbed_files) do
          [File.join(public_root, 'javascripts', 'another_script.js'),
           File.join(public_root, 'javascripts', 'a_script.js')]
        end

        let(:wrong_absolute_asset) do
          File.join(public_root, 'javascripts', 'absolute', 'package.js')
        end

        let(:correct_absolute_asset) do
          File.join(public_root, 'absolute', 'package.js')
        end

        it "should not return nil" do
          subject.assets[:javascripts].should_not be_nil
        end

        it "should list asset four asset files" do
          subject.assets[:javascripts].length.should eql 4
        end

        it "should support glob characters" do
          subject.assets[:javascripts].should include(*globbed_files)
        end

        it "should not include non-existent asset files" do
          subject.assets[:javascripts].should_not include('doesnt_exist.js')
        end

        it "should not include duplicate asset files" do
          subject.assets[:javascripts].count(
           File.join(public_root, 'javascripts', 'jquery.js')).should eql 1
        end

        it "should not prepend the asset type for absolute paths" do
          subject.assets[:javascripts].should_not include wrong_absolute_asset
          subject.assets[:javascripts].should include correct_absolute_asset
        end
      end

      context "asset type doesn't exist," do
        it "should return nil" do
          subject.assets[:stylesheets].should be_nil
        end
      end

      context "dependency loading," do
        let(:base_assets_hash) do
          assets_fixture[:base]
        end

        let(:base_assets) do
          [File.join(public_root, 'javascripts', 'base_1.js'),
           File.join(public_root, 'javascripts', 'base_2.js')]
        end

        let(:foo_assets) do
          [File.join(public_root, 'javascripts', 'foo_1.js')]
        end

        let(:ordered_assets) do
           [File.join(public_root, 'javascripts', 'base_1.js'),
            File.join(public_root, 'javascripts', 'base_2.js'),
            File.join(public_root, 'javascripts', 'foo_1.js'),
            "#{public_root}/javascripts/a_script.js",
             "#{public_root}/javascripts/another_script.js",
             "#{public_root}/javascripts/jquery.js",
             "#{public_root}/absolute/package.js"]

        end

        before do
          assets[:javascripts] << {:include => ["base", "foo"]}
          packager.stub(:packages) do
            {
              :base   => {:javascripts => base_assets},
              :foo    => {:javascripts => foo_assets}
            }
          end
        end

        it "should add the files from the other package" do
          subject.assets[:javascripts].should include(*base_assets)
        end

        it "should list the files from the dependency first" do
          subject.assets[:javascripts].should eql ordered_assets
        end

        it "should remove the include line" do
          subject.assets[:javascripts].should_not include(':include')
        end

        it "should not include duplicate asset files" do
          subject.assets[:javascripts].count(
           File.join(public_root, 'javascripts', 'jquery.js')).should eql 1
        end
      end
    end

    describe "#packit," do
      let(:packer) { double(Packers::Javascript) }

      before do
        subject.stub(:get_packer) { packer }
      end

      context "asset type exists," do
        before do
          packer.stub(:concatenate) { 'concatenated' }
          packer.stub(:pack)        { 'packed' }
        end

        it "should concatenate assets" do
          packer.should_receive(:concatenate) { 'concatenated' }
          subject.packit(:javascripts)
        end

        context "minify_assets is enabled," do
          before do
            Palmade::AssetPackager.stub_chain(:configuration, :minify_assets?) { true }
          end

          it "should minify assets" do
            packer.should_receive(:pack) { 'packed' }
            subject.packit(:javascripts)
          end

          it "should return minified asset" do
            asset = subject.packit(:javascripts)
            asset.should include 'packed'
          end
        end

        context "minify_assets isn't enabled," do
          before do
            Palmade::AssetPackager.stub(:minify_assets) { false }
          end

          it "should not minify assets" do
            packer.should_not_receive(:pack)
            subject.packit(:javascripts)
          end

          it "should return concatenated assets, only" do
            asset = subject.packit(:javascripts)
            asset.should include 'concatenated'
            asset.should_not include 'packed'
          end
        end
      end

      context "asset type doesn't exist," do
        it "should not do anything" do
          subject.packit(:stylesheets).should eql nil
        end
      end
    end

    describe "#paths," do
      let(:individual_urls) do
        ['/javascripts/a_script.js',
         '/javascripts/another_script.js',
         '/javascripts/jquery.js',
         '/absolute/package.js'
        ]
      end

      let(:doesnt_exist) { '/javascripts/doesnt_exist.js' }

      it "should return the individual urls for the assets" do
        subject.paths(:javascripts).should eql individual_urls
      end

      it "should not include assets that don't exist" do
        subject.paths(:javascripts).should_not include doesnt_exist
      end

      context "package_assets is enabled" do
        before { Palmade::AssetPackager.stub_chain(:configuration, :package_assets?) { true } }

        it "should return the url for the package" do
          subject.paths(:javascripts).should eql '/assets/javascripts/signin.js'
        end

        context "url for deflated packed package," do
          it "should return the url for the deflated package" do
            subject.paths(:javascripts, :deflated => true).should eql '/assets/javascripts/signin.js.z'
          end
        end
      end
    end

  end
end
