require 'tmpdir'

# Option parsing, --input, and error reporting are specified in dl-core.
RSpec.describe HAL::Downloader::CLI do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  before do
    stub_request(:get, 'https://hal.science/hal-01207234v1/json')
      .to_return(status: 200, body: File.read('spec/fixtures/http/json-hal-01207234v1.json'))
    stub_request(:get, 'https://hal.science/hal-01207234v1/document')
      .to_return(status: 200, body: File.binread('spec/fixtures/http/pdf-hal-01207234v3.pdf'))
    stub_request(:get, 'https://hal.science/hal-01207234v1/tei')
      .to_return(status: 200, body: File.read('spec/fixtures/http/tei-hal-01207234v3.xml'))
    stub_request(:get, 'https://hal.science/hal-01057111/json')
      .to_return(status: 200, body: File.read('spec/fixtures/http/json-hal-01057111.json'))
  end

  def run_with arguments
    described_class.new(arguments, stderr:, stdout:).run
  end

  it 'archives a HAL URL and prints its folder' do
    Dir.mktmpdir do |root|
      status = run_with ['-p', root, '--rate-limit', '0', 'https://hal.science/hal-01207234v1/document']

      expect(status).to eq 0
      expect(stdout.string).to include 'hal-01207234-constructive-solution'
    end
  end

  it 'reports a metadata-only record and exits non-zero' do
    Dir.mktmpdir do |root|
      expect(run_with(['-p', root, '--rate-limit', '0', 'hal-01057111'])).to eq 1
      expect(stderr.string).to eq "hal-01057111: #{HAL::Downloader::NoFile.new.message}\n"
    end
  end

  it "uses hal-dl's usage line and version" do
    run_with ['-h']
    run_with ['--version']

    expect(stdout.string).to start_with 'Usage: hal-dl [options] <HAL_ID_OR_URL>'
    expect(stdout.string).to end_with "#{HAL::Downloader::VERSION}\n"
  end
end
