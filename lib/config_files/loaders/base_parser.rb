module ConfigFiles
  module Loaders
    # Base class providing common parsing functionality for configuration file loaders
    class BaseParser
      class << self
        def call(file_name)
          content = File.read(file_name)
          parse(content)
        end

        private

        # Template method to be implemented by subclasses
        def parse(content)
          raise NotImplementedError, "Subclasses must implement #parse"
        end

        # Common value parsing logic shared across parsers
        def parse_value(value)
          return nil if value.nil?
          return value if value.empty?

          # Try to parse as boolean
          boolean_value = parse_boolean(value)
          return boolean_value unless boolean_value.nil?

          # Try to parse as number
          number_value = parse_number(value)
          return number_value unless number_value.nil?

          # Return as string
          value
        end

        # Parse boolean values with common representations
        def parse_boolean(value)
          case value.downcase
          when 'true', 'yes', 'on', '1'
            true
          when 'false', 'no', 'off', '0'
            false
          else
            nil
          end
        end

        # Parse numeric values (integers and floats)
        def parse_number(value)
          return value.to_i if integer?(value)
          return value.to_f if float?(value)
          nil
        end

        # Check if string represents an integer
        def integer?(value)
          value.match?(/^\d+$/)
        end

        # Check if string represents a float
        def float?(value)
          value.match?(/^\d+\.\d+$/)
        end

        # Remove surrounding quotes from a value
        def unquote(value)
          value.gsub(/^["']|["']$/, '')
        end

        # Check if line is a comment based on comment prefixes
        def comment?(line, prefixes = ['#'])
          prefixes.any? { |prefix| line.start_with?(prefix) }
        end

        # Check if line is empty or whitespace only
        def empty_line?(line)
          line.strip.empty?
        end

        # Skip processing for comments and empty lines
        def skip_line?(line, comment_prefixes = ['#'])
          empty_line?(line) || comment?(line, comment_prefixes)
        end

        # Parse section header like [section_name]
        def parse_section_header(line)
          match = line.match(/^\[(.+)\]$/)
          match ? match[1].strip : nil
        end

        # Check if line is a section header
        def section_header?(line)
          line.match?(/^\[.+\]$/)
        end

        # Set nested value using dot notation (e.g., "server.host" -> {"server" => {"host" => value}})
        def set_nested_value(hash, key_path, value, section = nil)
          keys = key_path.split('.')
          target = section ? (hash[section] ||= {}) : hash

          # Navigate to the nested location
          keys[0..-2].each do |key|
            target = (target[key] ||= {})
          end

          # Set the final value
          target[keys.last] = value
        end

        # Check if key contains dot notation for nesting
        def nested_key?(key)
          key.include?('.')
        end

        # Set value in hash, handling sections and nesting
        def set_value(hash, key, value, current_section = nil)
          parsed_value = parse_value(value)

          if nested_key?(key)
            set_nested_value(hash, key, parsed_value, current_section)
          elsif current_section
            hash[current_section][key] = parsed_value
          else
            hash[key] = parsed_value
          end
        end

        # Initialize section in hash if it doesn't exist
        def ensure_section(hash, section_name)
          hash[section_name] ||= {}
        end
      end
    end
  end
end