$LOAD_PATH.push(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'minitest/autorun'
require 'config_files'

class MultiDirectoryDummy
  include ConfigFiles
  config_directories etc: ['test/config', 'test/etc', 'test/local']
  static_config_files :dummy
end

class MultiDirectoryDynamic
  include ConfigFiles
  config_directories etc: ['test/config', 'test/etc', 'test/local']
  dynamic_config_files :dummy
end

class SingleDirectoryForComparison
  include ConfigFiles
  config_directories etc: ['test/etc']
  static_config_files :dummy
end

class MissingDirTest
  include ConfigFiles
  config_directories etc: ['test/nonexistent', 'test/etc']
  static_config_files :dummy
end

class NoFilesTest
  include ConfigFiles
  config_directories etc: ['test/config', 'test/etc', 'test/local']
  static_config_files :nonexistent
end

class MultiDirectoryTest < Minitest::Test
  def test_loads_from_all_directories
    config = MultiDirectoryDummy.dummy

    # Should have values from all directories
    assert config.key?(:config_test), "Should have config_test key"
    assert config.key?(:only_in_config), "Should have only_in_config from config dir"
    assert config.key?(:only_in_yaml), "Should have only_in_yaml from etc dir"
    assert config.key?(:only_in_local), "Should have only_in_local from local dir"
  end

  def test_earlier_directories_override_later_ones
    config = MultiDirectoryDummy.dummy

    # config_test should be from config directory (first in list)
    assert_equal 'config_dir_value', config[:config_test]

    # shared_key should also be from config directory (first in list)
    assert_equal 'from_config', config[:shared_key]
  end

  def test_deep_merge_behavior_for_nested_hashes
    config = MultiDirectoryDummy.dummy

    # Database config should be deep merged with config dir taking precedence
    assert config[:database], "Should have database config"
    assert_equal 'config.example.com', config[:database][:host], "Host should be from config dir (highest priority)"
    assert_equal 5432, config[:database][:port], "Port should come from config dir"
    assert_equal 'local_user', config[:database][:username], "Username should come from local dir (only place it exists)"
  end

  def test_json_files_are_also_merged_across_directories
    config = MultiDirectoryDummy.dummy

    # API config should be deep merged from JSON files with config dir taking precedence
    assert config[:api], "Should have API config from JSON files"
    assert_equal 'https://api.config.com', config[:api][:endpoint], "Endpoint should be from config dir (highest priority)"
    assert_equal 30, config[:api][:timeout], "Timeout should come from config dir"
    assert config[:api][:debug], "Debug should come from local dir (only place it exists)"
  end

  def test_array_values_in_nested_structures_are_merged
    config = MultiDirectoryDummy.dummy

    # Features should be merged with config dir taking precedence
    assert config[:features], "Should have features config"
    assert config[:features][:feature_a], "feature_a should come from config dir"
    refute config[:features][:feature_b], "feature_b should be from config dir (highest priority)"
    assert config[:features][:feature_c], "feature_c should come from local dir (only place it exists)"
  end

  def test_dynamic_config_files_also_work_with_multiple_directories
    config = MultiDirectoryDynamic.dummy

    # Should behave the same as static config files
    assert_equal 'config_dir_value', config[:config_test]
    assert config.key?(:only_in_config)
    assert config.key?(:only_in_yaml)
    assert config.key?(:only_in_local)
  end

  def test_single_directory_behavior_unchanged
    config = SingleDirectoryForComparison.dummy

    # Should only have values from etc directory
    assert_equal 'test', config[:config_test]
    assert config.key?(:only_in_yaml)
    refute config.key?(:only_in_config), "Should not have config dir values"
    refute config.key?(:only_in_local), "Should not have local dir values"
  end

  def test_missing_directories_are_handled_gracefully
    config = MissingDirTest.dummy
    # Should still work with existing directories
    assert_equal 'test', config[:config_test]
  end

  def test_empty_result_when_no_files_found
    config = NoFilesTest.nonexistent

    assert_empty(config)
  end

  def test_file_extensions_are_processed_correctly_across_directories
    config = MultiDirectoryDummy.dummy

    # Should have values from .yml, .json, and .conf files across all directories
    assert config.key?(:only_in_yaml), "Should process .yml files"
    assert config.key?(:testId), "Should process .json files"
    assert config.key?(:only_in_conf), "Should process .conf files"
  end
end
