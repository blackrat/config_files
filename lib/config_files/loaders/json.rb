require 'json'

module ConfigFiles
  module Loaders
    class Json
      class << self
        def call(file_name, object_class: ::Hash)
          ::JSON.parse(::File.read(file_name), { object_class: object_class, quirks_mode: true })
        end
      end
    end
  end
end
