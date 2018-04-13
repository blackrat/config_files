require 'json'

module ConfigFiles
  module Loaders
    class Json
      class << self
        def call(file_name, object_class: ::OpenStruct)
          ::JSON.load(file_name, nil, {object_class: object_class})
        end
      end
    end
  end
end
