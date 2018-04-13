module ConfigFiles
  module Loaders
    class Yaml
      class << self
        def call(file_name)
          ::YAML.load_file(file_name)
        end
      end
    end
  end
end
