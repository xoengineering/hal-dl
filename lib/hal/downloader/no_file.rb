module HAL
  module Downloader
    class NoFile < Error
      def initialize message = 'metadata-only record: HAL has no file for it'
        super
      end
    end
  end
end
