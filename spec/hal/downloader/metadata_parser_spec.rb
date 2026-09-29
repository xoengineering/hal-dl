RSpec.describe HAL::Downloader::MetadataParser do
  def parse fixture
    described_class.new(File.read("spec/fixtures/http/#{fixture}.json")).metadata
  end

  describe '#metadata for a record with a file' do
    let(:metadata) { parse 'json-hal-01207234' }

    it 'extracts the ID, version, and versioned URL' do
      expect(metadata.hal_id).to  eq 'hal-01207234'
      expect(metadata.version).to eq 3
      expect(metadata.hal_url).to eq 'https://hal.science/hal-01207234v3'
    end

    it 'extracts the title, abstract, and document type' do
      expect(metadata.title).to eq 'Constructive solution of inverse parametric linear/quadratic programming problems'
      expect(metadata.abstract).to start_with 'Parametric convex programming has received a lot of attention'
      expect(metadata.doc_type).to eq 'REPORT'
    end

    it 'extracts authors in order, each with their primary affiliations' do
      nguyen = metadata.authors.first

      expect(metadata.authors.map(&:name)).to eq [
        'Ngoc Anh Nguyen', 'Sorin Olaru', 'Pedro Rodriguez-Ayerbe', 'Morten Hovd', 'Ion Necoara'
      ]
      expect(nguyen.affiliations).to include 'Johannes Kepler University', 'Laboratoire des signaux et systèmes'
    end

    it 'keeps the publication date as given and the submission date as a date' do
      expect(metadata.published).to eq '2015-09-30'
      expect(metadata.submitted).to eq '2016-09-14'
    end

    it 'extracts the primary domain as id and English name' do
      expect(metadata.domain).to eq(id: 'spi.auto', name: 'Engineering Sciences [physics]/Automatic')
    end

    it 'extracts the licence, language, and how it was submitted' do
      expect(metadata.licence).to     eq 'https://about.hal.science/hal-authorisation-v1/'
      expect(metadata.language).to    eq 'en'
      expect(metadata.submit_type).to eq 'file'
    end
  end

  describe '#bibtex' do
    it "is HAL's own BibTeX entry" do
      parser = described_class.new File.read('spec/fixtures/http/json-hal-01207234.json')

      expect(parser.bibtex).to start_with '@techreport{nguyen:hal-01207234,'
    end
  end

  describe '#metadata for an earlier version' do
    let(:metadata) { parse 'json-hal-01207234v1' }

    it 'is that version' do
      expect(metadata.version).to   eq 1
      expect(metadata.hal_url).to   eq 'https://hal.science/hal-01207234v1'
      expect(metadata.submitted).to eq '2015-09-30'
    end
  end

  describe '#metadata for a metadata-only record' do
    let(:metadata) { parse 'json-hal-01057111' }

    it 'extracts the journal details and external identifiers' do
      expect(metadata.submit_type).to eq 'notice'
      expect(metadata.journal).to     eq 'FEMS Microbiology Letters'
      expect(metadata.volume).to      eq '357'
      expect(metadata.issue).to       eq '1'
      expect(metadata.pages).to       eq '63-68'
      expect(metadata.doi).to         eq '10.1111/1574-6968.12489'
      expect(metadata.pubmed_id).to   eq '24888447'
      expect(metadata.arxiv_id).to    be_nil
    end

    it 'keeps a year-only publication date as given' do
      expect(metadata.published).to eq '2014'
    end
  end

  context 'when HAL returns no document' do
    it 'raises PaperNotFound' do
      json = '{"response":{"numFound":0,"start":0,"docs":[]}}'

      expect { described_class.new(json).metadata }.to raise_error HAL::Downloader::PaperNotFound
    end
  end
end
