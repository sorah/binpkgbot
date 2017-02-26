require 'binpkgbot/tasks/base'
require 'binpkgbot/tasks/concern/emerge'

module Binpkgbot
  module Tasks
    class Upgrade < Base
      include Concern::Emerge

      def run
        name = @options[:name] || @options[:atom]
        unless name
          raise ArgumentError, "upgrade task is missing :name -- what to upgrade? e.g. @world"
        end

        emerge(name, '-uDN', ephemeral: @options.key?(:persist) ? !@options[:persist] : false)
      end
    end
  end
end
