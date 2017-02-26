require 'binpkgbot/tasks/base'
require 'binpkgbot/tasks'

module Binpkgbot
  module Tasks
    class Include < Base
      def run
        name = @options[:name]
        raise ArgumentError, "include task is missing :name -- what to include?" unless name
        Dir.glob[name].sort.each do |path|
          yaml = YAML.load_file(path)
          if yaml.kind_of?(Array)
            raise ArgumentError, "#{path} should be an array of task definitions"
          end
          yaml.each do |task_def|
            Tasks.from_definition(task_def, config: @config).execute
          end
        end
      end
    end
  end
end
