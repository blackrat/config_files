require 'json'

module ConfigFiles
  module Loaders
    class Json
      class << self
        def call(file_name, object_class: ::Hash)
          ::JSON.load(::File.open(file_name), nil, {object_class: object_class, quirks_mode: true})
        end
      end
    end
  end
end
