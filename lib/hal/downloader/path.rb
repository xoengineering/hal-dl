module HAL
  module Downloader
    # The paper's folder, shared by all its versions
    class Path
      def initialize metadata
        @metadata = metadata
      end

      def to_s
        [date_dir, domain, "#{@metadata.hal_id}-#{slug}"].join '/'
      end

      private

      # 2015-09-30 becomes 2015/09/30; a year-only or year-month date gives a shorter path
      def date_dir
        date = @metadata.published || @metadata.submitted
        date.to_s.split('-').join '/'
      end

      def domain
        @metadata.domain[:id]
      end

      def slug
        DL::Core::Slug.new(@metadata.title).to_s
      end
    end
  end
end
