lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'config_files/version'

Gem::Specification.new do |spec|
  spec.authors     = ['Paul McKibbin']
  spec.email       = ['pmckibbin@gmail.com']
  spec.description = 'A configuration tool for using multiple configuration files with multiple formats by presenting them as a hash.'
  spec.summary     = <<-SUMMARY
  ConfigFiles is a configuration file access tool. It parses multiple configuration files in multiple formats and
  presents a consistent block to the application with options to cache or use the files dynamically
SUMMARY

  spec.homepage    = 'https://github.com/blackrat/config_files'
  spec.files       = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.test_files  = spec.files.grep(%r{^(test|spec|features)/})
  spec.name        = 'config_files'
  spec.require_paths = ['lib']
  spec.version     = ConfigFiles::VERSION
  spec.license     = 'MIT License'
  spec.date        = '2012-11-11'

  spec.add_dependency 'activesupport'
end