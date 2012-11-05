module Palmade::AssetPackager
  module Mixins::LegacyCompatibility

    def change_pipes_to_commas(abs_path)
      basename     = File.basename(abs_path)

      return abs_path unless basename.index('|')

      new_basename = "{#{basename.gsub('|', ',')}}"

      abs_path.sub(/#{Regexp.escape(basename)}$/, new_basename)
    end
  end
end
