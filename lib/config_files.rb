require 'config_files/file_factory'
require 'config_files/loader_factory'
require 'config_files/loaders'
require 'config_files/version'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/object/blank'

require 'meta'
require 'yaml'

class NoDirectoryEntry < NoMethodError; end
module ConfigFiles

  class << self
    def included(base)
      base.class_eval do
        extend ConfigFilesClassMethods
      end
    end
  end

  module ConfigFilesClassMethods
    include Meta
    attr_accessor :directories

    def self.extended(base)
      base.instance_eval do
        self.directories=default_directories
      end
    end

    def any_extension
      '*'
    end

    def config_key
      :etc
    end

    def default_directories
      { :etc => ['config', 'etc', '/etc'] }
    end

    def config_directories(*arr)
      self.directories||=default_directories
      arr.each do |directory_list|
        directory_list.each do |key, value|
          self.directories[key]=value.map { |dir| ::File.expand_path(dir) }
          meta_def("#{key}_dir") { @directories[key] }
        end
      end
    end

    def merged_hash(file)
      config_files(file).inject(::HashWithIndifferentAccess.new) { |master, file|  master.deep_merge(FileFactory.(file)) }
    end

    def build_combined(file)
      merged_hash(file)
    end

    def static_config_files(*arr)
      arr.each do |file|
        content=build_combined(file)
        meta_def(file) { content }
      end
    end

    def dynamic_config_files(*arr)
      arr.each do |file|
        meta_def(file) { build_combined(file) }
      end
    end

    alias_method :config_files, :dynamic_config_files

    private
    def directory_listing(directory, file)
      ::Dir.glob(::File.join(directory, "#{file}.*"))
    end

    def first_directory(file, key=config_key)
      begin
        self.directories[key]&.detect { |directory| directory_listing(directory, file).presence } || ''
      rescue NoMethodError=>e
        raise NoDirectoryEntry, "Unable to find #{key} in #{self.directories}"
      end
    end

    def files(file, key=config_key)
      directory_listing(first_directory(file, key), file)
    end

    def config_files(file, key=config_key)
      files(file, key)
    end
  end
end
