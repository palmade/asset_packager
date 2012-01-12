module Palmade::AssetPackager::Packers
  shared_examples "a packer" do
    subject { described_class }

    describe "#concatenate," do
      let(:sources) do
        {
          'packer_file_a' => 'contents from a',
          'packer_file_b' => 'contents from b'
        }
      end
      subject do
        described_class.concatenate(sources.keys,
                                    :public_root =>
                                      '/tmp/rspec_asset_packager.txt')
      end

      before do
        sources.each do |name, contents|
          file = double(File)
          file.stub(:read) { contents }
          File.stub(:open).with(name, anything).and_yield(file)
          File.stub(:read).with(name) { contents }
        end
      end

      it "should concatenate the sources" do
        subject.should match /^contents from a$/
        subject.should match /^contents from b$/
      end

      it "should have a newline between the sources" do
        subject.should match /\A(^contents from a\n*)\n+(^contents from b\n*)\Z/
      end
    end

    describe "#pack," do
      it { should respond_to :pack }
    end
  end
end
