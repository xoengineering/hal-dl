require 'dl/core'

require_relative 'downloader/error'      # before errors below that subclass Error
require_relative 'downloader/identifier' # after error
require_relative 'downloader/version'

module HAL
  module Downloader
  end
end
