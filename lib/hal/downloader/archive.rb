require 'fileutils'

module HAL
  module Downloader
    class Archive
      def initialize identifier, root:, client: Client.new
        @identifier = identifier
        @root       = root
        @client     = client
      end

      # Downloads into <destination>.partial/ and
      # renames it into place only once everything succeeded.
      # An archived version is always complete and is skipped.
      # PaperFolder decides flat (single version) vs v<N>/ (several versions).
      def run
        raise NoFile unless metadata.submit_type == 'file'
        return paper_folder.location_of(metadata.version) if paper_folder.archived? metadata.version

        paper_folder.unflatten!
        FileUtils.rm_rf staging_dir
        FileUtils.mkdir_p staging_dir

        download_pdf
        download_tei
        write_sidecars

        File.rename staging_dir, destination
        destination
      end

      private

      def parser
        @parser ||= MetadataParser.new fetch_metadata
      end

      # the requested version, or the latest when none was requested
      def fetch_metadata
        @client.get("https://hal.science/#{@identifier}/json").to_s
      rescue HTTPError => e
        raise PaperNotFound if e.status == 404

        raise
      end

      def metadata
        @metadata ||= parser.metadata
      end

      # the version HAL actually returned, so every download matches the metadata
      def archived
        @archived ||= Identifier.new "#{metadata.hal_id}v#{metadata.version}"
      end

      def paper_folder
        @paper_folder ||= PaperFolder.new File.join(@root, Path.new(metadata).to_s)
      end

      # evaluated after unflatten!, which can turn a flat folder into v<N>/ folders
      def destination
        @destination ||= paper_folder.destination_for metadata.version
      end

      # a sibling of destination, so the rename is a single atomic step
      def staging_dir
        "#{destination}.partial"
      end

      def download_pdf
        body = @client.get("https://hal.science/#{archived}/document").to_s
        File.binwrite File.join(staging_dir, "#{archived.file_stem}.pdf"), body
      end

      # HAL's own TEI metadata, verbatim, when it has it
      def download_tei
        body = @client.get("https://hal.science/#{archived}/tei").to_s
        File.write File.join(staging_dir, 'hal.xml'), body
      rescue HTTPError => e
        raise unless e.status == 404
      end

      def write_sidecars
        body = MarkdownBody.new(metadata).to_s

        DL::Core::Sidecar::Markdown.new(metadata, body:).write to: staging_dir
        DL::Core::Sidecar::YAML.new(metadata).write            to: staging_dir
        DL::Core::Sidecar::JSON.new(metadata).write            to: staging_dir
        File.write File.join(staging_dir, 'metadata.bib'), parser.bibtex
      end
    end
  end
end
