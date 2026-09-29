require 'uri'

module HAL
  module Downloader
    # A HAL document ID, with its version when one was given. IDs are a portal
    # prefix (hal, tel, halshs, inria, hal-pasteur, …), a dash, and eight digits.
    class Identifier
      class Invalid < Error; end

      ID = /\A(?<id>[a-z][a-z0-9]*(?:-[a-z0-9]+)*-\d{8})(?:v(?<version>\d+))?\z/

      attr_reader :id, :version, :input

      def initialize input
        @input = input
        match  = parse input.to_s.strip
        raise Invalid, "not a HAL identifier: #{input}" if match.nil?

        @id      = match[:id]
        @version = match[:version] && Integer(match[:version])
      end

      # the URL form: hal-01207234, or hal-01207234v3 when a version is known
      def to_s = version.nil? ? id : "#{id}v#{version}"

      # HAL IDs have no slashes, so to_s is already a single path segment
      def file_stem = to_s

      private

      def parse text
        ID.match(text) || parse_url(text)
      end

      # hal.science, its portals (theses.hal.science, …), and the older archives-ouvertes.fr hosts
      def parse_url text
        uri  = URI.parse(text.include?('://') ? text : "https://#{text}")
        host = uri.host.to_s
        return unless host == 'hal.science' || host.end_with?('.hal.science', 'archives-ouvertes.fr')

        first_segment = uri.path.to_s.split('/').reject(&:empty?).first
        ID.match first_segment.to_s
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
