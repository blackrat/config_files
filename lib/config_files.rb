require 'meta'
require 'yaml'
module ConfigFiles

  class << self
    def included(base)
      base.class_eval do
        extend ClassMethods
      end
    end
  end

  module ClassMethods
    include Meta
    attr_accessor :directories

    def yaml_extension
      '.yml'
    end

    def config_key
      :etc
    end

    def config_directories(*arr)
      self.directories||={ :etc => ['etc', '/etc'] }
      arr.each do |directory_list|
        directory_list.each do |key, value|
          self.directories[key]=value.map { |dir| File.expand_path(dir) }
          meta_def("#{key}_dir") { @directories[key] }
        end
      end
    end

    def static_config_files(*arr)
      arr.each do |file|
        content=YAML.load_file(config_file(file))
        meta_def(file) { content }
      end
    end

    def dynamic_config_files(*arr)
      arr.each do |file|
        meta_def(file) { YAML.load_file(config_file(file)) }
      end
    end

    alias_method :config_files, :dynamic_config_files

    private
    def first_directory(file, key=config_key)
      self.directories[key].find { |directory|
        File.exists?(File.join(directory, "#{file}#{yaml_extension}"))
      } || (raise Errno::ENOENT, "No #{file}#{yaml_extension} in #{self.directories[key]}")
    end

    def config_file(file, key=config_key)
      File.join(first_directory(file, key), "#{file}#{yaml_extension}")
    end
  end
end
