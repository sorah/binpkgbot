require 'binpkgbot/utils'

module Binpkgbot
  module Tasks
    def self.from_definition(defi, config: nil)
      case defi
      when String, Symbol
        self.find(defi).new(config: config)
      when Hash
        raise ArgumentError, "task defiification should not have more than 2 keys when it's a Hash" if defi.size > 1
        kind = defi.keys.first
        options = defi.values.first
        options = {name: options} unless options.kind_of?(Hash)
        self.find(kind).new(config: config, **Utils.symbolize_keys(options))
      end
    end

    def self.find(name)
      const = Binpkgbot::Tasks
      prefix = 'binpkgbot/tasks'

      retried = false
      constant_name = name.to_s.gsub(/\A.|_./) { |s| s[-1].upcase }

      begin
        const.const_get constant_name, false
      rescue NameError
        unless retried
          begin
            require "#{prefix}/#{name}"
          rescue LoadError
          end

          retried = true
          retry
        end

        nil
      end
    end
  end
end
