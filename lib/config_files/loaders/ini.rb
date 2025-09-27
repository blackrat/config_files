require_relative 'base_parser'

module ConfigFiles
  module Loaders
    class Ini < BaseParser
      # INI files support both # and ; for comments
      COMMENT_PREFIXES = ['#', ';'].freeze

      class << self
        private

        def parse(content)
          result = {}
          current_section = nil

          content.each_line do |line|
            line = line.strip
            next if skip_line?(line, COMMENT_PREFIXES)

            if section_header?(line)
              current_section = parse_section_header(line)
              ensure_section(result, current_section)
              next
            end

            key, value = parse_ini_line(line)
            next unless key && value

            set_value(result, key, value, current_section)
          end

          result
        end

        # Parse INI format line (key=value only)
        def parse_ini_line(line)
          return [nil, nil] unless line.include?('=')

          key, value = line.split('=', 2)
          key = key.strip
          value = unquote(value.strip)

          [key, value]
        end
      end
    end
  end
end
