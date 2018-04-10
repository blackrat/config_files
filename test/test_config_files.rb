$:.push(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'minitest/autorun'
require 'config_files'
class Dummy
  include ConfigFiles
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

class YAMLConfigTest < MiniTest::Test
  def test_yaml_extension
    assert_equal('.yml', Dummy.yaml_extension)
  end

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

  def test_raise_for_missing_files
    assert_raises(Errno::ENOENT) { Dummy.broken }
  end

  def test_yaml_and_config_override
    assert_equal('test2', Dummy2.dummy[:config_test])
  end
end