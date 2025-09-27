require 'rexml/document'
require_relative 'base_parser'

module ConfigFiles
  module Loaders
    class Xml < BaseParser
      class << self
        private

        def parse(content)
          doc = REXML::Document.new(content)
          doc.root ? parse_element(doc.root) : {}
        end

        def parse_element(element)
          result = parse_attributes(element)
          parse_child_elements(element, result)

          # Return text content if element has no children or attributes
          return parse_text_content(element) if result.empty? && element.has_text?

          result
        end

        # Parse element attributes, prefixing with @
        def parse_attributes(element)
          result = {}
          element.attributes.each do |name, value|
            result["@#{name}"] = parse_value(value)
          end
          result
        end

        # Parse child elements, handling duplicates and nesting
        def parse_child_elements(element, result)
          element.elements.each do |child|
            key = child.name
            child_value = child.has_elements? ? parse_element(child) : parse_leaf_element(child)

            if result.key?(key)
              result[key] = convert_to_array(result[key])
              result[key] << child_value
            else
              result[key] = child_value
            end
          end
        end

        # Parse leaf element (no child elements)
        def parse_leaf_element(element)
          text = element.text
          text ? parse_value(text.strip) : nil
        end

        # Parse text content of element
        def parse_text_content(element)
          parse_value(element.text.strip)
        end

        # Convert single value to array for handling multiple elements with same name
        def convert_to_array(value)
          value.is_a?(Array) ? value : [value]
        end
      end
    end
  end
end
