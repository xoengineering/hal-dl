## [0.1.0]

First version. Per-paper offline archive of HAL (hal.science) papers, any version, built on [dl-core](https://github.com/xoengineering/dl-core).

- Accepts HAL IDs with any portal prefix (`hal-`, `tel-`, `halshs-`, `hal-pasteur-`, …), with or without a version, and hal.science, portal, and archives-ouvertes.fr URLs.
- Saves the deposited PDF, HAL's TEI metadata verbatim, and four sidecar metadata files; `metadata.bib` is HAL's own BibTeX. Authors carry their primary affiliations.
- Layout: `YYYY/MM/DD/<domain>/<hal-id>-<slug>/`, flat for a paper with only v1 archived, `v<N>/` folders otherwise.
- Metadata-only records raise `HAL::Downloader::NoFile`; unknown IDs raise `HAL::Downloader::PaperNotFound`.
- Rate-limited HTTP client (3s default) with timeouts and retries on 429/503, staged downloads that skip already-archived versions, and a CLI with `--input FILE|-`, per-target error reporting, and exit status 1 on any failure, all from dl-core.
