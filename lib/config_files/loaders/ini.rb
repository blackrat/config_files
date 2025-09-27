module ConfigFiles
  module Loaders
    class Ini
      class << self
        def call(file_name)
          content = File.read(file_name)
          parse_ini(content)
        end

        private

        def parse_ini(content)
          result = {}
          current_section = nil
          
          content.each_line do |line|
            line = line.strip
            
            # Skip empty lines and comments
            next if line.empty? || line.start_with?('#', ';')
            
            # Handle sections [section_name]
            if line.match(/^\[(.+)\]$/)
              current_section = $1.strip
              result[current_section] = {} unless result[current_section]
              next
            end
            
            # Handle key=value pairs
            if line.include?('=')
              key, value = line.split('=', 2)
              key = key.strip
              value = value.strip
              
              # Remove quotes if present
              value = value.gsub(/^["']|["']$/, '')
              
              # Convert to appropriate type
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