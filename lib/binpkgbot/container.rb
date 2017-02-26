require 'binpkgbot/utils'
require 'tmpdir'
require 'shellwords'
require 'pathname'

module Binpkgbot
  class Container
    class ContainerFailure < StandardError; end

    COPY_TMPDIR = "/.binpkgbot.copies"
    WORKDIR = "/.binpkgbot.work"
    SHAREDIR = "/.binpkgbot.share"

    SHAREDIR_SRC = File.expand_path("../../share", __dir__)
    def initialize(directory, ephemeral: true, binds: [], copies: [], env: {}, script:, config: nil)
      @directory = directory
      @ephemeral = ephemeral
      @env = env
      @binds = normalize_binds(binds)
      @copies = normalize_copies(copies)
      @script = script
      @config = config
    end

    def workdir
      @workdir ||= Pathname.new(Dir.mktmpdir)
    end

    def script
      parts = ['set -e']
      @copies.each do |copy| 
        parts.push <<-EOF
if [ -e #{copy[:to].shellescape} ]; then
  rm -rf #{copy[:to].shellescape}
fi
cp -pr #{COPY_TMPDIR}-#{copy[:id]} #{copy[:to].shellescape}
        EOF
      end
      parts.push @env.map { |k, v| "export #{k}=#{v.shellescape}" }.join("\n")
      parts << @script
      parts.join("\n\n")
    end

    def binds
      @binds + \
        normalize_binds(@config&.binds || []) + \
        @copies.map { |copy| {from: copy[:from], to: "/#{COPY_TMPDIR}-#{copy[:id]}", writable: false} } + \
        [
          {from: workdir, to: WORKDIR, writable: true},
          {from: SHAREDIR_SRC, to: SHAREDIR, writable: false},
        ]
    end

    def command_line
      [
        @config.use_sudo_for_nspawn? ? 'sudo' : nil,
        'systemd-nspawn',
        "--directory=#{@directory}",
        @ephemeral ? "--ephemeral" : nil,
        binds.map { |_| "--bind#{_[:writable] ? nil : '-ro'}=#{_[:from]}:#{_[:to]}" },
        '/bin/bash'
      ].flatten.compact
    end

    def run(error: true)
      puts script.each_line.map.with_index { |_,i| _.strip.empty? ? nil : "#{(i.zero? ? "$ " : "  ")}#{_.chomp}" }.compact.join(?\n)
      r,w = IO.pipe
      w.puts script
      pid = spawn(*command_line, in: r)
      puts "--> #{command_line.shelljoin}"
      r.close
      w.close
      _, status = Process.waitpid2(pid)
      if error && !status.success?
        raise ContainerFailure, "container failed #{status.inspect}, #{command_line.inspect}"
      end
      status
    end

    private

    def normalize_binds(binds)
      Utils.symbolize_keys(binds || []).map do |bind|
        case
        when bind.kind_of?(String)
          {from: bind, to: bind, writable: false}
        when bind.kind_of?(Hash) && bind[:ro]
          {from: bind[:ro], to: bind[:ro], writable: false}
        when bind.kind_of?(Hash) && bind[:rw]
          {from: bind[:rw], to: bind[:rw], writable: true}
        when bind.kind_of?(Hash)
          bind
        else
          raise ArgumentError, "Unknown --bind specification: #{bind.inspect}"
        end
      end
    end

    def normalize_copies(copies)
      Utils.symbolize_keys(copies || []).map.with_index do |copy, idx|
        case
        when copy.kind_of?(String)
          {id: idx, from: copy, to: copy}
        when copy.kind_of?(Hash)
          copy.merge(id: idx)
        else
          raise ArgumentError, "Unknown copy specification: #{copy.inspect}"
        end
      end
    end
  end
end
