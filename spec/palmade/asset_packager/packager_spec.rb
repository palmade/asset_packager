require 'spec_helper'

module Palmade::AssetPackager
  describe Packager do

    let(:configuration) do
      configuration = double(Configuration)
      configuration.stub(:public_root)     { public_root }
      configuration.stub(:package_dir)     { package_dir }
      configuration.stub(:minify_assets?)  { false }
      configuration.stub(:deflate_assets?) { false }
      configuration.stub(:package_assets?) { false }
      configuration.stub(:options) do
        {:base          => assets_fixture[:base]}
      end
      configuration
    end

    let(:package) { double(Package) }

    subject { Palmade::AssetPackager::Packager.new :packages =>
                                              configuration.options }

    before do
      Palmade::AssetPackager.stub(:configuration) { configuration }
      Palmade::AssetPackager::Package.stub(:new) { package }
    end

    it "should successfully instantiate" do
      subject
    end

    context "one package declaration," do
      let(:correct_packages) { {:base => package} }

      before do
        Palmade::AssetPackager::Package.should_receive(:new) { package }
      end

      its(:packages) { should eql correct_packages }
    end

    context "multiple package declaration, " do
      before do
        options = configuration.options
        options[:another_package] =
           {:javascripts => ['another_one.js']}

        require 'pp'
        configuration.stub(:options) { options }
      end

      before do
        Palmade::AssetPackager::Package.should_receive(:new).twice { package }
      end

      let(:package) { double(Package) }
      let(:correct_packages) do
        {:base => package,
         :another_package => package}
      end

      its(:packages) { should eql correct_packages }
    end

    describe "#cache" do
      let(:output_dir) { 'somewhere'  }
      let(:type)       { :javascripts }
      let(:filename)   { 'base.js'    }
      let(:complete_path) { "#{output_dir}/#{type}/#{filename}" }
      let(:deflated_path) { "#{output_dir}/#{type}/#{filename}.z" }

      before do
        double(FileUtils)
        File.stub(:exists?).with("#{output_dir}/#{type}") { true }
        File.stub(:open) { false }
        package.should_receive(:filename) { filename }
      end

      after do
        subject.cache(:base, :javascripts, 'hello', output_dir)
      end

      context "output_dir/type exists" do
        it "should not create output_dir" do
          FileUtils.should_not_receive(:mkdir_p)
        end
      end

      context "output_dir/type doesn't exist" do
        before do
          File.stub(:exists?).with("#{output_dir}/#{type}") { false }
        end

        it "should create directory" do
          FileUtils.should_receive(:mkdir_p)
        end
      end

      context "`base` package with `javascripts` type and `hello` content" do
        let(:deflate_object) do
          deflate_object = double(Zlib::Deflate)
          deflate_object.stub(:deflate)
          deflate_object.stub(:close)
          deflate_object
        end

        before do
          Zlib::Deflate.stub(:new) { deflate_object }
        end

        let(:file) do
          double(File)
        end

        it "should write the package to specified output_dir" do
          File.should_receive(:open).
            with(complete_path, 'wb+').
            and_yield(file)
          file.should_receive(:write).with('hello')
        end

        it "should write the raw deflated package to specified output_dir" do
          file.stub(:<<)

          File.should_receive(:open).
            with(deflated_path, 'wb+').
            and_yield(file)

          file.should_receive(:<<).with('foo')
          deflate_object.should_receive(:deflate).with('hello', Zlib::FINISH).and_return('--foo****')
        end
      end
    end
  end
end
