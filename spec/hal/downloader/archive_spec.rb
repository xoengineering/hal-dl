require 'tmpdir'

RSpec.describe HAL::Downloader::Archive do
  let(:client)     { HAL::Downloader::Client.new(rate_limit: 0) }
  let(:identifier) { HAL::Downloader::Identifier.new 'hal-01207234' }
  let(:paper_dir)  do
    '2015/09/30/spi.auto/hal-01207234-constructive-solution-of-inverse-parametric-linear-slash-quadratic-programming'
  end

  let(:pdf) { File.binread 'spec/fixtures/http/pdf-hal-01207234v3.pdf' }
  let(:tei) { File.read 'spec/fixtures/http/tei-hal-01207234v3.xml' }

  before do
    stub_request(:get, 'https://hal.science/hal-01207234/json')
      .to_return(status: 200, body: File.read('spec/fixtures/http/json-hal-01207234.json'))
    stub_request(:get, 'https://hal.science/hal-01207234v1/json')
      .to_return(status: 200, body: File.read('spec/fixtures/http/json-hal-01207234v1.json'))
    stub_request(:get, 'https://hal.science/hal-01207234v3/document').to_return(status: 200, body: pdf)
    stub_request(:get, 'https://hal.science/hal-01207234v3/tei').to_return(status: 200, body: tei)
    stub_request(:get, 'https://hal.science/hal-01207234v1/document').to_return(status: 200, body: pdf)
    stub_request(:get, 'https://hal.science/hal-01207234v1/tei').to_return(status: 200, body: tei)
  end

  def run_in root, input = identifier
    described_class.new(input, root: root, client: client).run
  end

  describe '#run' do
    it 'archives the latest version in v<N>/, since a v3 paper has other versions' do
      Dir.mktmpdir do |root|
        dir = run_in root

        expect(dir).to eq File.join(root, paper_dir, 'v3')
        expect(File.binread(File.join(dir, 'hal-01207234v3.pdf'))).to eq pdf
        expect(File.read(File.join(dir, 'hal.xml'))).to eq tei
        %w[metadata.md metadata.yaml metadata.json metadata.bib].each do |name|
          expect(File).to exist File.join(dir, name)
        end
      end
    end

    it "writes HAL's own BibTeX" do
      Dir.mktmpdir do |root|
        dir = run_in root

        expect(File.read(File.join(dir, 'metadata.bib'))).to start_with '@techreport{nguyen:hal-01207234,'
      end
    end

    it 'cites the HAL URL in the Markdown body' do
      Dir.mktmpdir do |root|
        dir = run_in root

        expect(File.read(File.join(dir, 'metadata.md'))).to include 'https://hal.science/hal-01207234v3'
      end
    end

    it 'archives v1 flat when it is the only version archived' do
      Dir.mktmpdir do |root|
        dir = run_in root, HAL::Downloader::Identifier.new('hal-01207234v1')

        expect(dir).to eq File.join(root, paper_dir)
        expect(File).to exist File.join(dir, 'hal-01207234v1.pdf')
      end
    end

    it 'archives a requested earlier version beside the later one' do
      Dir.mktmpdir do |root|
        run_in root
        dir = run_in root, HAL::Downloader::Identifier.new('hal-01207234v1')

        expect(dir).to eq File.join(root, paper_dir, 'v1')
        expect(File).to exist File.join(root, paper_dir, 'v1', 'hal-01207234v1.pdf')
        expect(File).to exist File.join(root, paper_dir, 'v3', 'hal-01207234v3.pdf')
      end
    end

    it 'skips a version already archived' do
      Dir.mktmpdir do |root|
        run_in root
        run_in root

        expect(WebMock).to have_requested(:get, 'https://hal.science/hal-01207234v3/document').once
      end
    end

    context 'when HAL has no TEI for the version' do
      before { stub_request(:get, 'https://hal.science/hal-01207234v3/tei').to_return(status: 404) }

      it 'archives the rest' do
        Dir.mktmpdir do |root|
          dir = run_in root

          expect(File).to     exist File.join(dir, 'hal-01207234v3.pdf')
          expect(File).not_to exist File.join(dir, 'hal.xml')
        end
      end
    end

    context 'when the record is metadata only' do
      before do
        stub_request(:get, 'https://hal.science/hal-01057111/json')
          .to_return(status: 200, body: File.read('spec/fixtures/http/json-hal-01057111.json'))
      end

      it 'raises NoFile and writes nothing' do
        Dir.mktmpdir do |root|
          expect { run_in root, HAL::Downloader::Identifier.new('hal-01057111') }
            .to raise_error HAL::Downloader::NoFile
          expect(Dir.children(root)).to be_empty
        end
      end
    end

    context 'when HAL has no such document' do
      before { stub_request(:get, 'https://hal.science/hal-99999999/json').to_return(status: 404) }

      it 'raises PaperNotFound' do
        Dir.mktmpdir do |root|
          expect { run_in root, HAL::Downloader::Identifier.new('hal-99999999') }
            .to raise_error HAL::Downloader::PaperNotFound
        end
      end
    end
  end
end
