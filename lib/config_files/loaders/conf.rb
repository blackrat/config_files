require_relative 'base_parser'

module ConfigFiles
  module Loaders
    class Conf < BaseParser
      class << self
        private

        def parse(content)
          result = {}
          current_section = nil

          content.each_line do |line|
            line = line.strip
            next if skip_line?(line)

            if section_header?(line)
              current_section = parse_section_header(line)
              ensure_section(result, current_section)
              next
            end

            key, value = parse_conf_line(line)
            next unless key && value

            set_value(result, key, value, current_section)
          end

          result
        end

        # Parse CONF format line supporting multiple syntaxes:
        # key=value, key: value, key value (space-separated)
        def parse_conf_line(line)
          key, value = extract_key_value_pair(line)
          return [nil, nil] unless key && value

          key = key.strip
          value = unquote(value.strip)

          [key, value]
        end

        # Extract key-value pair from line using different separators
        def extract_key_value_pair(line)
          SEPARATORS.each do |separator|
            if line.include?(separator)
              parts = line.split(separator, 2)
              return parts if parts.length == 2
            end
          end

          [nil, nil]
        end

        # Supported key-value separators in order of preference
        SEPARATORS = ['=', ':', ' '].freeze
      end
    end
  end
end
