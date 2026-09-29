require 'dl/core'

require_relative 'downloader/author'
require_relative 'downloader/error'           # before errors below that subclass Error
require_relative 'downloader/identifier'      # after error
require_relative 'downloader/metadata'
require_relative 'downloader/metadata_parser'
require_relative 'downloader/paper_not_found' # after error
require_relative 'downloader/version'

module HAL
  module Downloader
  end
end
