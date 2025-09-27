module ConfigFiles
  module Loaders
    class Conf
      class << self
        def call(file_name)
          content = File.read(file_name)
          parse_conf(content)
        end

        private

        def parse_conf(content)
          result = {}
          current_section = nil
          
          content.each_line do |line|
            line = line.strip
            
            # Skip empty lines and comments (CONF uses # primarily)
            next if line.empty? || line.start_with?('#')
            
            # Handle sections [section_name]
            if line.match(/^\[(.+)\]$/)
              current_section = $1.strip
              result[current_section] = {} unless result[current_section]
              next
            end
            
            # Handle multiple CONF syntax styles
            key, value = parse_conf_line(line)
            next unless key && value
            
            # Handle nested keys (dot notation)
            if key.include?('.')
              set_nested_value(result, key, parse_value(value), current_section)
            else
              parsed_value = parse_value(value)
              if current_section
                result[current_section][key] = parsed_value
              else
                result[key] = parsed_value
              end
            end
          end
          
          result
        end
        
        def parse_conf_line(line)
          # Support multiple CONF syntax styles:
          # key=value
          # key: value  
          # key value (space-separated)
          
          if line.include?('=')
            key, value = line.split('=', 2)
          elsif line.include?(':')
            key, value = line.split(':', 2)
          elsif line.include?(' ')
            parts = line.split(' ', 2)
            key, value = parts if parts.length == 2
          else
            return [nil, nil]
          end
          
          return [nil, nil] unless key && value
          
          key = key.strip
          value = value.strip
          
          # Remove quotes if present
          value = value.gsub(/^["']|["']$/, '')
          
          [key, value]
        end
        
        def set_nested_value(hash, key_path, value, section = nil)
          keys = key_path.split('.')
          target = section ? (hash[section] ||= {}) : hash
          
          keys[0..-2].each do |key|
            target = (target[key] ||= {})
          end
          
          target[keys.last] = value
        end
        
        def parse_value(value)
          # Try to parse as boolean
          case value.downcase
          when 'true', 'yes', 'on', '1'
            return true
          when 'false', 'no', 'off', '0'
            return false
          end
          
          # Try to parse as integer
          if value.match(/^\d+$/)
            return value.to_i
          end
          
          # Try to parse as float
          if value.match(/^\d+\.\d+$/)
            return value.to_f
          end
          
          # Return as string
          value
        end
      end
    end
  end
end