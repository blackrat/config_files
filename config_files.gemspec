lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'config_files/version'

Gem::Specification.new do |spec|
  spec.authors     = ['Paul McKibbin']
  spec.email       = ['pmckibbin@gmail.com']
  spec.description = 'Configuration tool for cascading configuration files with multiple formats'
  spec.summary     = <<-SUMMARY
  ConfigFiles is a configuration file access tool. It parses multiple configuration files in multiple formats and
  presents a consistent block to the application with options to cache or use the files dynamically. It uses a priority
  directory ordering to find the files, and an alphabetical ordering to give precedence to the files in that directory.
  SUMMARY

  spec.homepage    = 'https://github.com/blackrat/config_files'
  spec.files       = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.name        = 'config_files'
  spec.require_paths = ['lib']
  spec.version     = ConfigFiles::VERSION
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'activesupport', '>= 6.1', '< 8.0'
  spec.add_dependency 'rexml', '~> 3.2'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
