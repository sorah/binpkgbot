module Binpkgbot
  module Tasks
    class Base
      def initialize(config: nil, **options)
        @config = config
        @options = options
      end

      attr_reader :config, :options

      def execute
        puts "==> #{self.class}: #{options.inspect}"
        run
      end

      private

      def run
        raise NotImplementedError
      end
    end
  end
end
