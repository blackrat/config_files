$:.push(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'minitest/autorun'
require 'config_files'
class LoaderFactoryDummy
  class << self
    def call(file_name, options={})
      nil
    end
  end
end

class LoaderFactoryTest < MiniTest::Test
  def file_locations
    File.join(__dir__, 'etc')
  end

  def test_detect_yaml_file_type
    assert_equal(::ConfigFiles::Loaders::Yaml, ::ConfigFiles::LoaderFactory.(File.join(file_locations,'dummy.yml')))
  end

  def test_detect_json_file_type
    assert_equal(::ConfigFiles::Loaders::Json, ::ConfigFiles::LoaderFactory.(File.join(file_locations,'dummy.json')))
  end

  def test_detect_unknown_file_type
    assert_nil(::ConfigFiles::LoaderFactory.(File.join(file_locations,'dummy.wibble'), default_loader: nil))
  end

  def test_allow_addition_of_file_types_does_not_break_existing
    assert_equal(::ConfigFiles::Loaders::Yaml, ::ConfigFiles::LoaderFactory.(File.join(file_locations,'dummy.yml'), loaders: {LoaderFactoryDummy=>['wibble']}))
  end

  def test_allow_addition_of_file_types_breaks_existing_if_specified
    assert_nil(::ConfigFiles::LoaderFactory.(File.join(file_locations,'dummy.yml'), loaders: {LoaderFactoryDummy=>['wibble']}, include_default: false, default_loader: nil))
  end

  def test_addition_of_new_loaders
    assert_equal(LoaderFactoryDummy, ::ConfigFiles::LoaderFactory.(File.join(file_locations,'dummy.wibble'), loaders: {LoaderFactoryDummy=>['wibble']}, include_default: false))
  end
end