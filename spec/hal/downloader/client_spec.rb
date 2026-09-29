# Rate limiting, retries, and timeouts are specified in dl-core.
RSpec.describe HAL::Downloader::Client do
  it 'is a DL::Core::Client' do
    expect(described_class.new).to be_a DL::Core::Client
  end

  it 'identifies hal-dl with version and source URL' do
    expect(described_class.new.user_agent)
      .to eq "hal-dl/#{HAL::Downloader::VERSION} (+https://github.com/xoengineering/hal-dl)"
  end

  it 'defaults to a 3-second rate limit' do
    expect(described_class.new.rate_limit).to eq 3
  end
end
