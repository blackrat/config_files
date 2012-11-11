$:.push(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'test/unit'
require 'yaml_config'
class Dummy
  include YAMLConfig
  config_directories :etc => ['etc', 'nofiles/etc']
  config_files :dummy, :broken
end

class Dummy2 < Dummy
  config_directories 'config' => ['etc', 'nofiles/etc']
  class << self
    def yaml_extension
      ".conf"
    end

    def config_key
      "config"
    end
  end
end

class YAMLConfigTest < Test::Unit::TestCase
  def test_yaml_extension
    assert_equal(Dummy.yaml_extension, '.yml')
  end

  def test_config_key
    assert_equal(Dummy.config_key, :etc)
  end

  def test_directory_is_initialized
    assert_not_nil(Dummy.directories)
  end

  def test_has_created_methods
    assert_not_nil(Dummy.etc_dir)
  end

  def test_created_paths_for_directories
    assert_equal(Dummy.etc_dir, ['etc', 'nofiles/etc'])
  end

  def test_created_variables
    assert_equal(Dummy.dummy[:config_test], 'test')
  end

  def test_raise_for_missing_files
    assert_raise(Errno::ENOENT) { Dummy.broken }
  end

  def test_yaml_and_config_override
    assert_equal(Dummy2.dummy[:config_test], 'test2')
  end
end