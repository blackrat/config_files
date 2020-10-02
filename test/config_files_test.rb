$:.push(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'minitest/autorun'
require 'config_files'
class Dummy
  include ConfigFiles
  config_directories :etc => ['etc', 'nofiles/etc']
  static_config_files :dummy, :broken
end

class Dummy2 < Dummy
  config_directories 'config' => ['etc', 'nofiles/etc']
  class << self
    def config_key
      "config"
    end
  end
end

class ConfigFilesTest < MiniTest::Test
  def test_config_key
    assert_equal(:etc, Dummy.config_key)
  end

  def test_directory_is_initialized
    assert(Dummy.directories)
  end

  def test_has_created_methods
    assert(Dummy.etc_dir)
  end

  def test_created_paths_for_directories
    assert_equal([File.join(__dir__, 'etc'), File.join(__dir__, 'nofiles/etc')], Dummy.etc_dir)
  end

  def test_created_variables
    assert_equal('test', Dummy.dummy[:config_test])
  end

  def test_empty_for_missing_files
    assert_equal({}, Dummy.broken)
  end

  def test_yaml_and_config_override
    assert_equal('test', Dummy2.dummy[:config_test])
  end
end