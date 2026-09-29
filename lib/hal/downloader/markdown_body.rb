module HAL
  module Downloader
    # The body of metadata.md. HAL's terms ask users to cite the HAL URL.
    class MarkdownBody
      def initialize metadata
        @metadata = metadata
      end

      def to_s
        <<~MARKDOWN

          # #{@metadata.title}

          #{authors_list}

          #{details_list}

          ## Abstract

          #{@metadata.abstract}
        MARKDOWN
      end

      private

      def authors_list
        @metadata.authors.map { |author| "- #{author_line author}" }.join "\n"
      end

      def author_line author
        return author.name if author.affiliations.empty?

        "#{author.name} (#{author.affiliations.join '; '})"
      end

      def details_list
        details = [
          "Published: #{@metadata.published}",
          "Domain: #{@metadata.domain[:id]} — #{@metadata.domain[:name]}",
          "HAL: [#{@metadata.hal_id}v#{@metadata.version}](#{@metadata.hal_url})"
        ]
        details << "DOI: [#{@metadata.doi}](https://doi.org/#{@metadata.doi})" if @metadata.doi
        details << "arXiv: [#{@metadata.arxiv_id}](https://arxiv.org/abs/#{@metadata.arxiv_id})" if @metadata.arxiv_id
        details << "Licence: #{@metadata.licence}" if @metadata.licence

        details.map { "- #{it}" }.join "\n"
      end
    end
  end
end
