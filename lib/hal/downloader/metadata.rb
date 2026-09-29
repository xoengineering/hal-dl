module HAL
  module Downloader
    # Field order is the reading order of the metadata sidecars.
    Metadata = Data.define(
      :hal_id,
      :version,
      :hal_url,
      :title,
      :authors,
      :abstract,
      :published,
      :submitted,
      :domain,
      :doc_type,
      :journal,
      :volume,
      :issue,
      :pages,
      :doi,
      :arxiv_id,
      :pubmed_id,
      :language,
      :keywords,
      :licence,
      :submit_type
    )
  end
end
