RSpec.describe HAL::Downloader::Identifier do
  describe '.new' do
    {
      'hal-01207234'                                        => ['hal-01207234', nil],
      ' hal-01207234 '                                      => ['hal-01207234', nil],
      'hal-01207234v1'                                      => ['hal-01207234', 1],
      'tel-00012345'                                        => ['tel-00012345', nil],
      'halshs-00012345v2'                                   => ['halshs-00012345', 2],
      'hal-pasteur-00012345'                                => ['hal-pasteur-00012345', nil],
      'https://hal.science/hal-01207234'                    => ['hal-01207234', nil],
      'https://hal.science/hal-01207234v3'                  => ['hal-01207234', 3],
      'https://hal.science/hal-01207234v3/document'         => ['hal-01207234', 3],
      'https://hal.science/hal-01207234/file/IPCP_JOTA.pdf' => ['hal-01207234', nil],
      'hal.science/hal-01207234'                            => ['hal-01207234', nil],
      'https://theses.hal.science/tel-00012345'             => ['tel-00012345', nil],
      'https://hal.archives-ouvertes.fr/hal-01207234v2'     => ['hal-01207234', 2],
      'https://halshs.archives-ouvertes.fr/halshs-00012345' => ['halshs-00012345', nil]
    }.each do |input, (id, version)|
      it "parses #{input.inspect}" do
        identifier = described_class.new input

        expect([identifier.id, identifier.version]).to eq [id, version]
      end
    end

    [
      nil,
      '',
      'not an id',
      'hal-123',
      '2508.16190',
      'https://example.com/hal-01207234',
      'https://hal.science/'
    ].each do |input|
      it "rejects #{input.inspect}" do
        expect { described_class.new input }.to raise_error described_class::Invalid
      end
    end

    it 'names the input in the error message' do
      expect { described_class.new 'not an id' }
        .to raise_error described_class::Invalid, 'not a HAL identifier: not an id'
    end
  end

  describe '#to_s' do
    it 'is the bare ID when no version was given' do
      expect(described_class.new('https://hal.science/hal-01207234').to_s).to eq 'hal-01207234'
    end

    it 'includes the version when one was given' do
      expect(described_class.new('hal-01207234v1').to_s).to eq 'hal-01207234v1'
    end
  end

  describe '#file_stem' do
    it 'is the same as to_s: HAL IDs have no slashes' do
      expect(described_class.new('hal-01207234v1').file_stem).to eq 'hal-01207234v1'
    end
  end
end
