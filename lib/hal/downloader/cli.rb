module HAL
  module Downloader
    class CLI < DL::Core::CLI
      def program = 'hal-dl'

      def target_name = 'HAL_ID_OR_URL'

      # HAL_DOWNLOAD_PATH, HAL_RATE_LIMIT
      def env_prefix = 'HAL'

      def default_path = File.join(Dir.home, 'Downloads', 'HAL_Papers')

      def version = VERSION

      def user_agent = Client::USER_AGENT

      def client_for(rate_limit:, log:) = Client.new(rate_limit:, log:)

      def identifier_for(target) = Identifier.new(target)

      def archive_for(identifier, root:, client:) = Archive.new(identifier, root:, client:)
    end
  end
end
