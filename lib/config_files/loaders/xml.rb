require 'rexml/document'

module ConfigFiles
  module Loaders
    class Xml
      class << self
        def call(file_name)
          content = File.read(file_name)
          parse_xml(content)
        end

        private

        def parse_xml(content)
          doc = REXML::Document.new(content)
          result = {}
          
          # Start parsing from the root element
          if doc.root
            result = parse_element(doc.root)
          end
          
          result
        end
        
        def parse_element(element)
          result = {}
          
          # Handle attributes
          element.attributes.each do |name, value|
            result["@#{name}"] = parse_value(value)
          end
          
          # Handle child elements
          element.elements.each do |child|
            key = child.name
            
            # If there are multiple elements with the same name, create an array
            if result.key?(key)
              # Convert to array if not already
              result[key] = [result[key]] unless result[key].is_a?(Array)
              result[key] << parse_element(child)
            else
              # Check if this element has children or just text
              if child.has_elements?
                result[key] = parse_element(child)
              else
                # It's a leaf node, get the text content
                text = child.text
                result[key] = text ? parse_value(text.strip) : nil
              end
            end
          end
          
          # If the element has text content and no child elements, return the text
          if result.empty? && element.has_text?
            return parse_value(element.text.strip)
          end
          
          result
        end
        
        def parse_value(value)
          return nil if value.nil? || value.empty?
          
          # Try to parse as boolean
          case value.downcase
          when 'true'
            return true
          when 'false'
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