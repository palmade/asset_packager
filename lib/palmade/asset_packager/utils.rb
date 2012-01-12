module Palmade::AssetPackager
  class Utils

    def self.stringify_keys(hash)
      hash.inject({}) do |options, (key, value)|
        options[key.to_s] = value
        options
      end
    end

    def self.symbolize_keys(arg)
      case arg
      when Array
        arg.map { |elem| symbolize_keys elem }
      when Hash
        Hash[
          arg.map { |key, value|
            k = key.is_a?(String) ? key.to_sym : key
            v = symbolize_keys value
            [k,v]
        }]
      else
        arg
      end
    end
  end
end
