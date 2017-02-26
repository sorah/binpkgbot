module Binpkgbot
  module Utils
    def self.symbolize_keys(obj)
      case obj
      when Hash
        Hash[obj.map { |k, v| [k.is_a?(String) ? k.to_sym : k, symbolize_keys(v)] }]
      when Array
        obj.map { |v| symbolize_keys(v) }
      else
        obj
      end
    end
  end
end
