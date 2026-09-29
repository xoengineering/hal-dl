# Opt-in drift check against the real HAL site: `HAL_LIVE=1 script/test`.
# Fetches each record that has a recorded JSON fixture and expects it to parse
# into the same Metadata as the fixture. A failure means HAL's export changed
# (or a new version was deposited) and the fixture needs re-recording.
RSpec.describe HAL::Downloader::MetadataParser, :live do
  around do |example|
    WebMock.allow_net_connect!
    example.run
  ensure
    WebMock.disable_net_connect! allow_localhost: true
  end

  let(:client) { HAL::Downloader::Client.new }

  it 'parses the live HAL JSON the same as each recorded fixture' do
    aggregate_failures do
      Dir.glob('spec/fixtures/http/json-*.json').each do |path|
        hal_id   = File.basename(path, '.json').delete_prefix('json-')
        response = client.get "https://hal.science/#{hal_id}/json"

        live     = described_class.new(response.to_s).metadata
        recorded = described_class.new(File.read(path)).metadata

        expect(live).to eq(recorded), "#{hal_id} drifted from #{path}"
      end
    end
  end
end
