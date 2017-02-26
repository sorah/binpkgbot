require 'binpkgbot/emerge_runner'

module Binpkgbot
  module Tasks
    module Concern
      module Emerge
        def emerge_runner(script, **options)
          emerge(nil, script: script, **options)
        end

        def emerge(atom, *args, ephemeral: !@options[:persist], use: @options[:use], accept_keywords: @options.fetch(:accept_keywords, true), unmasks: @options[:unmasks], masks: @options[:masks], script: nil)
          EmergeRunner.new(
            atom, *args,
            ephemeral: ephemeral,
            use: use,
            accept_keywords: accept_keywords,
            unmasks: unmasks,
            masks: masks,
            config: @config,
            script: script,
          ).run
        end
      end
    end
  end
end
