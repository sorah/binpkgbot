require 'binpkgbot/tasks/base'
require 'binpkgbot/tasks/concern/emerge'

module Binpkgbot
  module Tasks
    class Run < Base
      include Concern::Emerge

      def run
        script = [*@options[:script],*@options[:scripts]].join("\n")
        if @options[:host]
          puts script.each_line.map.with_index { |_,i| "#{(i.zero? ? "$ " : "  ")}#{_}" }.join(?\n)
          r,w = IO.pipe
          w.puts script
          pid = spawn('bash', in: r)
          r.close
          w.close
          _, status = Process.waitpid2(pid)
          if !status.success?
            raise "host run failed #{status.inspect}, #{command_line.inspect}"
          end
        else
          emerge_runner(script, ephemeral: @options.key?(:persist) ? !@options[:persist] : false)
        end
      end
    end
  end
end
