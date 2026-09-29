RSpec.describe HAL::Downloader::Path do
  let(:metadata) { HAL::Downloader::MetadataParser.new(File.read('spec/fixtures/http/json-hal-01207234.json')).metadata }

  describe '#to_s' do
    it 'is YYYY/MM/DD/<domain>/<hal-id>-<slug>' do
      slug = 'constructive-solution-of-inverse-parametric-linear-slash-quadratic-programming'

      expect(described_class.new(metadata).to_s).to eq "2015/09/30/spi.auto/hal-01207234-#{slug}"
    end

    it 'uses only the date parts that are known' do
      expect(described_class.new(metadata.with(published: '2015')).to_s)
        .to start_with '2015/spi.auto/'
    end

    it 'falls back to the submission date when there is no publication date' do
      expect(described_class.new(metadata.with(published: nil)).to_s)
        .to start_with '2016/09/14/spi.auto/'
    end
  end
end
