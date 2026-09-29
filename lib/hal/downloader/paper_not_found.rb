module HAL
  module Downloader
    class PaperNotFound < Error
      def initialize message = 'no such document on HAL'
        super
      end
    end
  end
end
