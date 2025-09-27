$LOAD_PATH.push(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'minitest/autorun'
require 'config_files'
require 'fileutils'

class ComprehensiveMultiDirectoryTest < Minitest::Test
  def setup
    # Create a comprehensive test scenario with multiple directories and formats
    FileUtils.mkdir_p('test/comprehensive/global')
    FileUtils.mkdir_p('test/comprehensive/environment')
    FileUtils.mkdir_p('test/comprehensive/local')

    # Global config (YAML)
    File.write('test/comprehensive/global/app.yml', <<~YAML)
      database:
        host: global-db.example.com
        port: 5432
        pool_size: 10
      app:
        name: MyApp
        version: 1.0.0
        debug: false
      features:
        feature_a: true
        feature_b: false
      global_setting: true
    YAML

    # Environment config (JSON)
    File.write('test/comprehensive/environment/app.json', <<~JSON)
      {
        "database": {
          "host": "staging-db.example.com",
          "username": "staging_user",
          "password": "staging_pass"
        },
        "app": {
          "debug": true,
          "log_level": "debug"
        },
        "features": {
          "feature_b": true,
          "feature_c": true
        },
        "environment_setting": "staging"
      }
    JSON

    # Local config (both YAML and JSON to test within-directory merging)
    File.write('test/comprehensive/local/app.yml', <<~YAML)
      database:
        host: localhost
        port: 3306
      app:
        debug: false
        local_override: true
      local_yaml_setting: true
    YAML

    File.write('test/comprehensive/local/app.json', <<~JSON)
      {
        "database": {
          "host": "127.0.0.1",
          "ssl": true
        },
        "app": {
          "environment": "development"
        },
        "local_json_setting": true
      }
    JSON
  end

  def teardown
    FileUtils.rm_rf('test/comprehensive')
  end

  def test_comprehensive_multi_directory_multi_format_merging
    # Create test class with all directories
    comprehensive_class = Class.new do
      include ConfigFiles
      config_directories etc: [
        'test/comprehensive/global',
        'test/comprehensive/environment',
        'test/comprehensive/local',
      ]
      static_config_files :app
    end

    config = comprehensive_class.app

    # Test that all unique keys from all files are present
    assert config.key?(:global_setting), "Should have global-only setting"
    assert config.key?(:environment_setting), "Should have environment-only setting"
    assert config.key?(:local_yaml_setting), "Should have local YAML setting"
    assert config.key?(:local_json_setting), "Should have local JSON setting"

    # Test database configuration deep merging with global taking precedence
    db = config[:database]

    assert_equal 'global-db.example.com', db[:host], "Host should be from global YAML (highest priority)"
    assert_equal 5432, db[:port], "Port should be from global YAML"
    assert_equal 10, db[:pool_size], "Pool size should be from global YAML"
    assert_equal 'staging_user', db[:username], "Username should be from environment JSON"
    assert_equal 'staging_pass', db[:password], "Password should be from environment JSON"
    assert db[:ssl], "SSL should be from local JSON"

    # Test app configuration merging
    app = config[:app]

    assert_equal 'MyApp', app[:name], "Name should be from global YAML"
    assert_equal '1.0.0', app[:version], "Version should be from global YAML"
    refute app[:debug], "Debug should be from global YAML (highest priority)"
    assert_equal 'debug', app[:log_level], "Log level should be from environment JSON"
    assert app[:local_override], "Local override should be from local YAML"
    assert_equal 'development', app[:environment], "Environment should be from local JSON"

    # Test features array merging
    features = config[:features]

    assert features[:feature_a], "Feature A should be from global YAML"
    refute features[:feature_b], "Feature B should be from global YAML (highest priority)"
    assert features[:feature_c], "Feature C should be from environment JSON"

    # Test environment-specific setting
    assert_equal 'staging', config[:environment_setting], "Environment setting should be preserved"
  end

  def test_directory_order_matters
    # Test that directory order affects final values
    reverse_order_class = Class.new do
      include ConfigFiles
      config_directories etc: [
        'test/comprehensive/local',
        'test/comprehensive/environment',
        'test/comprehensive/global',
      ]
      static_config_files :app
    end

    config = reverse_order_class.app

    # With reversed order, local should override global (local comes first)
    assert_equal 'localhost', config[:database][:host], "Local should override global when local comes first"
    refute config[:app][:debug], "Local debug setting should override others"
  end

  def test_missing_directories_handled_gracefully
    # Test with some non-existent directories
    mixed_existence_class = Class.new do
      include ConfigFiles
      config_directories etc: [
        'test/comprehensive/nonexistent1',
        'test/comprehensive/global',
        'test/comprehensive/nonexistent2',
        'test/comprehensive/local',
      ]
      static_config_files :app
    end

    config = mixed_existence_class.app

    # Should still work with existing directories
    assert config.key?(:global_setting), "Should have global settings"
    assert config.key?(:local_yaml_setting), "Should have local settings"
    assert_equal 'global-db.example.com', config[:database][:host], "Should merge from existing directories (global overrides local)"
  end
end
