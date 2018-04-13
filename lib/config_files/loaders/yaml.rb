module ConfigFiles
  module Loaders
    class Yaml
      class << self
        def call(file_name, object_class: OpenStruct)
          JSON.parse(::YAML.load_file(file_name).to_json, object_class: object_class)
        end
      end
    end
  end
end
