require 'binpkgbot/container'
require 'shellwords'

module Binpkgbot
  class EmergeRunner
    def initialize(atom, *args, config:, ephemeral: true, use: [], accept_keywords: [], unmasks: [], masks: [], script: nil)
      @atom = atom
      @args = args
      @config = config
      @ephemeral = ephemeral
      @use = use
      @accept_keywords = accept_keywords
      @unmasks = unmasks
      @masks = masks
      @script = script
    end

    def binds
      [
        {from: @config.portage_repo, to: '/usr/portage', writable: true},
        *@config.binds
      ]
    end

    def copies
      [
        {from: @config.etc_portage, to: '/etc/portage'},
      ]
    end

    def env
      {
        FEATURES: "buildpkg",
        PORTAGE_ELOG_CLASSES: 'log warn error qa',
        PORTAGE_ELOG_SYSTEM: 'save save_summary',
        CONFIG_PROTECT_MASK: @config.config_protect_mask? ? @config.config_protect_mask : '/etc',
      }
    end

    def script
      @script || <<-EOF
set -x
/.binpkgbot.share/libexec/modify-etc-portage /.binpkgbot.work/package.use /etc/portage/package.use
/.binpkgbot.share/libexec/modify-etc-portage /.binpkgbot.work/package.accept_keywords /etc/portage/package.accept_keywords
/.binpkgbot.share/libexec/modify-etc-portage /.binpkgbot.work/package.unmasks /etc/portage/package.unmasks
/.binpkgbot.share/libexec/modify-etc-portage /.binpkgbot.work/package.masks /etc/portage/package.masks
emerge #{@config.emerge_options.shelljoin} #{@args.shelljoin} #{@atom.shellescape}
      EOF
    end

    def container
      @container ||= Container.new(
        @config.stage,
        ephemeral: @ephemeral,
        binds: binds,
        copies: copies,
        env: env,
        script: script,
        config: @config,
      )
    end

    def prepare_etc_portage_overrides
      {masks: @masks, unmasks: @unmasks}.each do |k,v|
        file = container.workdir.join("package.#{k}")
        content = []
        [v].flatten.each do |x|
          case x
          when true
            content << @atom
          when false
            # do nothing
          when String
            content << x
          when nil
          else
            raise TypeError, "Invalid type for #{k.inspect} specification on #{@atom}, it should be true or false or string: #{x.inspect}"
          end
        end
        File.write file, "#{content.join(?\n)}\n"
      end

      begin
        file = container.workdir.join("package.accept_keywords")
        content = []
        [@accept_keywords].flatten.each do |x|
          case x
          when true
            content << "#{@atom} ~*"
          when false
            # do nothing
          when String
            if x.split(/\s+/, 2).size > 1
              content << x
            else
              content << "#{x} ~*"
            end
          when nil
          else
            raise TypeError, "Invalid type for accept_keywords specification on #{@atom}, it should be true or false or string: #{x.inspect}"
          end
        end
        File.write file, "#{content.join(?\n)}\n"
      end

      begin
        file = container.workdir.join("package.use")
        content = []
        [@use].flatten.each do |x|
          case x
          when true
            content << "#{@atom} ~*"
          when false
            # do nothing
          when String
            if x.split(/\s+/, 2).size > 1
              content << x
            else
              content << "#{@atom} #{x}"
            end
          when nil
          else
            raise TypeError, "Invalid type for :use specification on #{@atom}, it should be true or false or string: #{x.inspect}"
          end
        end
        File.write file, "#{content.join(?\n)}\n"
      end
    end

    def run
      prepare_etc_portage_overrides
      container.run
    end

  end
end

