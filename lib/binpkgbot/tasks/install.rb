require 'binpkgbot/tasks/base'
require 'binpkgbot/tasks/concern/emerge'

module Binpkgbot
  module Tasks
    class Install < Base
      include Concern::Emerge

      def run
        name = @options[:name] || @options[:atom]
        unless name
          raise ArgumentError, "install task is missing :name and :atom -- what to install?"
        end

        emerge(name)
      end
    end
  end
end
