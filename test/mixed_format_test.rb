$:.push(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'minitest/autorun'
require 'config_files'
require 'fileutils'

class MixedFormatTest < Minitest::Test
  def setup
    # Create test directories and files with mixed formats
    FileUtils.mkdir_p('test/format_test/dir1')
    FileUtils.mkdir_p('test/format_test/dir2')
    FileUtils.mkdir_p('test/format_test/dir3')
    
    # dir1: YAML file
    File.write('test/format_test/dir1/config.yml', <<~YAML)
      database:
        host: yaml-host
        port: 5432
      app:
        name: yaml-app
        debug: false
      yaml_only: true
    YAML
    
    # dir2: JSON file
    File.write('test/format_test/dir2/config.json', <<~JSON)
      {
        "database": {
          "host": "json-host",
          "username": "json-user"
        },
        "app": {
          "name": "json-app",
          "version": "1.0.0"
        },
        "json_only": true
      }
    JSON
    
    # dir3: Both YAML and JSON files
    File.write('test/format_test/dir3/config.yml', <<~YAML)
      database:
        host: final-yaml-host
        password: secret
      app:
        debug: true
      final_yaml: true
    YAML
    
    File.write('test/format_test/dir3/config.json', <<~JSON)
      {
        "database": {
          "host": "final-json-host",
          "timeout": 30
        },
        "app": {
          "environment": "production"
        },
        "final_json": true
      }
    JSON
  end
  
  def teardown
    FileUtils.rm_rf('test/format_test') if Dir.exist?('test/format_test')
  end
  
  def test_mixed_yaml_and_json_across_directories
    # Test class that uses mixed format directories
    mixed_class = Class.new do
      include ConfigFiles
      config_directories etc: ['test/format_test/dir1', 'test/format_test/dir2', 'test/format_test/dir3']
      static_config_files :config
    end
    
    config = mixed_class.config
    
    # Test that values from all formats are present
    assert config.key?(:yaml_only), "Should have YAML-only value from dir1"
    assert config.key?(:json_only), "Should have JSON-only value from dir2"
    assert config.key?(:final_yaml), "Should have YAML value from dir3"
    assert config.key?(:final_json), "Should have JSON value from dir3"
    
    # Test deep merging across formats
    assert config[:database], "Should have database config"
    assert_equal 'final-yaml-host', config[:database][:host], "YAML from dir3 should override JSON from dir3 (alphabetical order)"
    assert_equal 5432, config[:database][:port], "Port should come from YAML in dir1"
    assert_equal 'json-user', config[:database][:username], "Username should come from JSON in dir2"
    assert_equal 'secret', config[:database][:password], "Password should come from YAML in dir3"
    assert_equal 30, config[:database][:timeout], "Timeout should come from JSON in dir3"
    
    # Test app config merging
    assert config[:app], "Should have app config"
    assert_equal 'production', config[:app][:environment], "Environment should come from JSON in dir3"
    assert_equal true, config[:app][:debug], "Debug should be overridden by YAML in dir3"
    assert_equal '1.0.0', config[:app][:version], "Version should come from JSON in dir2"
  end
  
  def test_multiple_files_same_directory_same_format
    # Test when a directory has multiple files of the same format
    FileUtils.mkdir_p('test/format_test/multi')
    
    File.write('test/format_test/multi/config.yml', <<~YAML)
      from_yml: true
      shared: yml_value
    YAML
    
    File.write('test/format_test/multi/config.json', <<~JSON)
      {
        "from_json": true,
        "shared": "json_value"
      }
    JSON
    
    multi_class = Class.new do
      include ConfigFiles
      config_directories etc: ['test/format_test/multi']
      static_config_files :config
    end
    
    config = multi_class.config
    
    # Both formats should be loaded and merged
    assert config.key?(:from_yml), "Should have YAML values"
    assert config.key?(:from_json), "Should have JSON values"
    
    # YAML should override JSON (alphabetical order: config.yml comes after config.json)
    assert_equal 'yml_value', config[:shared], "YAML should override JSON for same key"
  end
  
  def test_file_processing_order_within_directory
    # Test that files are processed in a predictable order within each directory
    FileUtils.mkdir_p('test/format_test/order')
    
    # Create files that will be processed in alphabetical order
    File.write('test/format_test/order/config.json', '{"order": "json", "source": "json"}')
    File.write('test/format_test/order/config.yml', "order: yaml\nsource: yaml")
    File.write('test/format_test/order/config.conf', ":order: conf\n:source: conf")
    
    order_class = Class.new do
      include ConfigFiles
      config_directories etc: ['test/format_test/order']
      static_config_files :config
    end
    
    config = order_class.config
    
    # The last file alphabetically should win (yml comes after json and conf)
    assert_equal 'yaml', config[:order]
    assert_equal 'yaml', config[:source]
  end
end