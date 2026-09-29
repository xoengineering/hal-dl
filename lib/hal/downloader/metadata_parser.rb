require 'json'

module HAL
  module Downloader
    # Parses HAL's JSON export of one document version (https://hal.science/<id>v<N>/json)
    class MetadataParser
      FACET_SEPARATOR = '_FacetSep_'.freeze
      JOIN_SEPARATOR  = '_JoinSep_'.freeze

      def initialize json
        @json = JSON.parse json
      end

      # HAL's own BibTeX entry, kept verbatim for metadata.bib
      def bibtex
        fields.fetch 'label_bibtex'
      end

      def metadata
        Metadata.new(
          hal_id:      fields['halId_s'],
          version:     fields['version_i'],
          hal_url:     fields['uri_s'],
          title:       Array(fields['title_s']).first,
          authors:     authors_from(fields),
          abstract:    Array(fields['abstract_s']).first,
          published:   fields['publicationDate_s'],
          submitted:   fields['submittedDate_s'].to_s[0, 10],
          domain:      domain_from(fields),
          doc_type:    fields['docType_s'],
          journal:     fields['journalTitle_s'],
          volume:      fields['volume_s'],
          issue:       Array(fields['issue_s']).first,
          pages:       fields['page_s'],
          doi:         fields['doiId_s'],
          arxiv_id:    fields['arxivId_s'],
          pubmed_id:   fields['pubmedId_s'],
          language:    Array(fields['language_s']).first,
          keywords:    Array(fields['keyword_s']),
          licence:     fields['licence_s'],
          submit_type: fields['submitType_s']
        )
      end

      private

      def fields
        @json.dig('response', 'docs', 0) || raise(PaperNotFound)
      end

      # authFullName_s and authIdFormPerson_s are parallel lists; affiliations
      # are "<form id>_FacetSep_<name>_JoinSep_<struct id>_FacetSep_<struct name>"
      def authors_from fields
        names    = Array(fields['authFullName_s'])
        form_ids = Array(fields['authIdFormPerson_s'])
        by_form  = affiliations_by_form_id fields['authIdHasPrimaryStructure_fs']

        names.each_with_index.map do |name, index|
          Author.new name:, affiliations: by_form.fetch(form_ids[index], [])
        end
      end

      def affiliations_by_form_id entries
        Array(entries).each_with_object({}) do |entry, by_form|
          author, structure = entry.split JOIN_SEPARATOR
          form_id           = author.split(FACET_SEPARATOR).first
          structure_name    = structure.to_s.split(FACET_SEPARATOR).last
          next if structure_name.nil?

          (by_form[form_id] ||= []) << structure_name
        end
      end

      # the English label for the primary domain: "spi.auto_FacetSep_Engineering Sciences [physics]/Automatic"
      def domain_from fields
        id    = fields['primaryDomain_s']
        label = Array(fields['en_domainAllCodeLabel_fs']).find { it.start_with? "#{id}#{FACET_SEPARATOR}" }

        { id:, name: label&.split(FACET_SEPARATOR)&.last }
      end
    end
  end
end
