# hal-dl

Download papers and metadata from [HAL](https://hal.science), France's national open archive, for offline archives.

For each paper version, `hal-dl` saves:

- The deposited PDF
- HAL's own TEI metadata (XML), verbatim
- Four sidecar metadata files: `metadata.md`, `metadata.yaml`, `metadata.json`, and `metadata.bib` (HAL's own BibTeX)

Any version can be archived, not just the latest.

## HAL's terms

From HAL's [legal aspects](http://doc.hal.science/en/legal-aspects/): HAL does not permit commercial use of extracted data; cite the source (the HAL URL, which `hal-dl` writes into every sidecar); authors retain their intellectual property rights, and each record's licence (recorded as `licence`) governs reuse of its files.

## Installation

```sh
gem install hal-dl
```

## CLI usage

```sh
hal-dl <HAL_ID_OR_URL> [<HAL_ID_OR_URL>...]
```

Accepted input forms:

| Form              | Example                                                                        |
| ----------------- | ------------------------------------------------------------------------------ |
| HAL ID            | `hal-01207234`, `tel-00012345`, `halshs-00012345`, `hal-pasteur-00012345`      |
| Versioned HAL ID  | `hal-01207234v1`                                                               |
| hal.science URL   | `https://hal.science/hal-01207234v3`, `https://hal.science/hal-01207234/document` |
| Portal URL        | `https://theses.hal.science/tel-00012345`                                      |
| Older HAL URL     | `https://hal.archives-ouvertes.fr/hal-01207234v2`                              |

An unversioned ID archives the latest version; a versioned ID archives that version.

### Flags

| Flag                      | Description                                                                   |
| ------------------------- | ----------------------------------------------------------------------------- |
| `-i FILE`, `--input FILE` | Read IDs/URLs from FILE, one per line (`-` for stdin; blanks and `#` skipped) |
| `-p PATH`, `--path PATH`  | Root download directory                                                       |
| `--rate-limit SECONDS`    | Seconds between HTTP requests; `0` disables throttling                        |
| `-v`, `--verbose`         | Print step lines and per-request URL/byte logs to stdout                      |
| `-q`, `--quiet`           | Print nothing to stdout; errors still go to stderr                            |
| `--version`               | Print the gem version and exit                                                |
| `-h`, `--help`            | Print help and exit                                                           |

`-v` and `-q` are mutually exclusive.

### Environment variables

| Variable            | Effect                                                          |
| ------------------- | --------------------------------------------------------------- |
| `HAL_DOWNLOAD_PATH` | Root download directory (default: `$HOME/Downloads/HAL_Papers`) |
| `HAL_RATE_LIMIT`    | Seconds between HTTP requests (default: `3`; `0` disables)      |

Precedence: CLI flag > ENV var > default.

### Errors and exit status

A target that fails (unrecognized ID, no such document, metadata-only record with no file, HTTP error, network failure) is reported on stderr as `<target>: <message>`, and the remaining targets still download. Exit status is `0` when every target succeeds and `1` when any fails.

## Output layout

```txt
$HAL_DOWNLOAD_PATH/                     # default: $HOME/Downloads/HAL_Papers
  YYYY/MM/DD/<domain>/<hal-id>-<slug>/
    <hal-id>v<N>.pdf
    hal.xml                             # HAL's TEI metadata, verbatim
    metadata.md                         # YAML frontmatter + Markdown body
    metadata.yaml
    metadata.json
    metadata.bib                        # HAL's own BibTeX
```

`YYYY/MM/DD` is the publication date (shorter when only the year or month is known; the submission date when there is none). `<domain>` is HAL's primary domain code (`spi.auto`, `sdv.gen`, …). `<slug>` is derived from the title.

A paper with only v1 archived is kept flat, as above. When a paper has more than one version, each version gets its own `v<N>/` folder with the same contents; archiving a second version of a flat paper first moves the existing files into `v<N>/`. A paper whose latest version is v2 or later starts out in `v<N>/` folders.

Each version downloads into a sibling `.partial` folder and is renamed into place only when every file succeeded. Re-running skips versions already archived.

## Library usage

```ruby
require 'hal/downloader'

identifier = HAL::Downloader::Identifier.new 'https://hal.science/hal-01207234v1'
client     = HAL::Downloader::Client.new                  # 3-second rate limit by default
path       = HAL::Downloader::Archive.new(identifier, root: '/tmp/papers', client: client).run
```

## Development

```sh
script/setup    # install dependencies
script/test     # run specs and rubocop
script/console  # interactive prompt
```

Specs run offline against recorded fixtures in `spec/fixtures/http/` (the PDF fixture is the first 4 KB of the real file). To check the JSON fixtures against the live HAL site, run:

```sh
HAL_LIVE=1 script/test
```

## License

MIT — see [LICENSE.md](LICENSE.md).

## Code of Conduct

This project follows the [Contributor Covenant](https://www.contributor-covenant.org/version/3/0/) 3.0 — see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
