require 'jsminc'

module Palmade::AssetPackager::Packers
  class Javascript

    class << self
      def concatenate(sources, options={})
        sources.collect { |source|
          File.open(source, 'rb:UTF-8') { |f| f.read }
        }.join("\n\n")
      end

      def pack(source)
        JSMinC.minify(source)
      end
    end
  end
end
