require 'date'
require 'fileutils'
require 'yaml'

module HAL
  module Downloader
    # One paper's folder. A paper with a single archived version is kept flat
    # (files directly in the folder); once a second version arrives, each
    # version gets its own v<N>/ folder.
    #
    # Copied from arxiv-dl without its html/ link rewriting (HAL archives have no html/);
    # to move into dl-core now that two gems use it.
    class PaperFolder
      VERSION_FOLDER = /\Av\d+(\.partial)?\z/

      attr_reader :path

      def initialize path
        @path = path
      end

      def archived? version
        Dir.exist? location_of(version)
      end

      def location_of version
        return path if flat_version == version

        version_path version
      end

      # where a new download of `version` goes; call unflatten! first if the folder is flat
      def destination_for version
        return path if version == 1 && !versioned?

        version_path version
      end

      # moves the flat version into v<N>/ so another version can sit beside it
      def unflatten!
        return if flat_version.nil?

        destination = version_path flat_version
        FileUtils.mkdir_p destination

        # metadata.yaml marks the folder as flat, so it moves last
        children = Dir.children(path) - [File.basename(destination), metadata_filename]
        children.each { FileUtils.mv File.join(path, it), destination }
        FileUtils.mv File.join(path, metadata_filename), destination
      end

      private

      def flat_version
        metadata_path = File.join path, metadata_filename
        return unless File.exist? metadata_path

        ::YAML.safe_load_file(metadata_path, permitted_classes: [Date]).fetch 'version'
      end

      def versioned?
        Dir.exist?(path) && Dir.children(path).any? { VERSION_FOLDER.match? it }
      end

      def version_path version
        File.join path, "v#{version}"
      end

      def metadata_filename
        DL::Core::Sidecar::YAML::FILENAME
      end
    end
  end
end
