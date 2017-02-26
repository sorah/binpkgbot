require 'optparse'
require 'binpkgbot/config'
require 'binpkgbot/version'

module Binpkgbot
  class Cli
    def initialize(argv)
      @argv = argv.dup
    end

    def run
      optparse.parse!(@argv)
      case options[:mode]
      when :version
        do_version
      when :run
        do_run
      end
    end

    def do_version
      puts "binpkgbot #{Binpkgbot::VERSION}"
      0
    end

    def do_run
      config.tasks.each do |task|
        task.execute
      end
      0
    end

    def options
      @options ||= {
        config: nil,
        mode: :run,
        debug: false,
      }
    end

    def optparse
      @optparse ||= OptionParser.new do |opt|
        opt.on('-v', '--version') { options[:mode] = :version }

        opt.on('-c PATH', '--config PATH', 'config file to use (default: ./binpkgbot.yml)') do |file|
          options[:config] = file
        end
      end
    end

    def config_path
      options[:config] || './binpkgbot.yml'
    end

    def config
      @config ||= Config.load_yaml(config_path)
    end
  end
end
