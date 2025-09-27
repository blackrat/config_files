require 'test_helper'
require 'tempfile'

class LoadersTest < Minitest::Test
  def setup
    @temp_files = []
  end

  def teardown
    @temp_files.each(&:unlink)
  end

  def create_temp_file(content, extension = '.tmp')
    file = Tempfile.new(['test', extension])
    file.write(content)
    file.close
    @temp_files << file
    file.path
  end

  # CONF Parser Tests
  def test_conf_parser_basic_key_value_pairs
    content = <<~CONF
      key1=value1
      key2: value2
      key3 value3
    CONF
    
    file_path = create_temp_file(content, '.conf')
    result = ConfigFiles::Loaders::Conf.call(file_path)
    
    assert_equal 'value1', result['key1']
    assert_equal 'value2', result['key2']
    assert_equal 'value3', result['key3']
  end

  def test_conf_parser_sections
    content = <<~CONF
      global_key=global_value
      
      [section1]
      key1=value1
      key2=value2
      
      [section2]
      key3=value3
    CONF
    
    file_path = create_temp_file(content, '.conf')
    result = ConfigFiles::Loaders::Conf.call(file_path)
    
    assert_equal 'global_value', result['global_key']
    assert_equal 'value1', result['section1']['key1']
    assert_equal 'value2', result['section1']['key2']
    assert_equal 'value3', result['section2']['key3']
  end

  def test_conf_parser_nested_keys
    content = <<~CONF
      server.host=localhost
      server.port=8080
      database.connection.host=db.example.com
      
      [app]
      cache.redis.host=redis.example.com
      cache.redis.port=6379
    CONF
    
    file_path = create_temp_file(content, '.conf')
    result = ConfigFiles::Loaders::Conf.call(file_path)
    
    assert_equal 'localhost', result['server']['host']
    assert_equal 8080, result['server']['port']
    assert_equal 'db.example.com', result['database']['connection']['host']
    assert_equal 'redis.example.com', result['app']['cache']['redis']['host']
    assert_equal 6379, result['app']['cache']['redis']['port']
  end

  def test_conf_parser_value_types
    content = <<~CONF
      string_value=hello world
      quoted_string="quoted value"
      single_quoted='single quoted'
      integer_value=42
      float_value=3.14
      boolean_true=true
      boolean_false=false
      boolean_yes=yes
      boolean_no=no
      boolean_on=on
      boolean_off=off
      boolean_1=1
      boolean_0=0
    CONF
    
    file_path = create_temp_file(content, '.conf')
    result = ConfigFiles::Loaders::Conf.call(file_path)
    
    assert_equal 'hello world', result['string_value']
    assert_equal 'quoted value', result['quoted_string']
    assert_equal 'single quoted', result['single_quoted']
    assert_equal 42, result['integer_value']
    assert_equal 3.14, result['float_value']
    assert_equal true, result['boolean_true']
    assert_equal false, result['boolean_false']
    assert_equal true, result['boolean_yes']
    assert_equal false, result['boolean_no']
    assert_equal true, result['boolean_on']
    assert_equal false, result['boolean_off']
    assert_equal true, result['boolean_1']
    assert_equal false, result['boolean_0']
  end

  def test_conf_parser_comments_and_empty_lines
    content = <<~CONF
      # This is a comment
      key1=value1
      
      # Another comment
      key2=value2
      
      [section]
      # Section comment
      key3=value3
    CONF
    
    file_path = create_temp_file(content, '.conf')
    result = ConfigFiles::Loaders::Conf.call(file_path)
    
    assert_equal 'value1', result['key1']
    assert_equal 'value2', result['key2']
    assert_equal 'value3', result['section']['key3']
  end

  # INI Parser Tests
  def test_ini_parser_basic_key_value_pairs
    content = <<~INI
      key1=value1
      key2=value2
    INI
    
    file_path = create_temp_file(content, '.ini')
    result = ConfigFiles::Loaders::Ini.call(file_path)
    
    assert_equal 'value1', result['key1']
    assert_equal 'value2', result['key2']
  end

  def test_ini_parser_sections
    content = <<~INI
      global_key=global_value
      
      [section1]
      key1=value1
      key2=value2
      
      [section2]
      key3=value3
    INI
    
    file_path = create_temp_file(content, '.ini')
    result = ConfigFiles::Loaders::Ini.call(file_path)
    
    assert_equal 'global_value', result['global_key']
    assert_equal 'value1', result['section1']['key1']
    assert_equal 'value2', result['section1']['key2']
    assert_equal 'value3', result['section2']['key3']
  end

  def test_ini_parser_value_types
    content = <<~INI
      string_value=hello world
      quoted_string="quoted value"
      single_quoted='single quoted'
      integer_value=42
      float_value=3.14
      boolean_true=true
      boolean_false=false
      boolean_yes=yes
      boolean_no=no
      boolean_on=on
      boolean_off=off
      boolean_1=1
      boolean_0=0
    INI
    
    file_path = create_temp_file(content, '.ini')
    result = ConfigFiles::Loaders::Ini.call(file_path)
    
    assert_equal 'hello world', result['string_value']
    assert_equal 'quoted value', result['quoted_string']
    assert_equal 'single quoted', result['single_quoted']
    assert_equal 42, result['integer_value']
    assert_equal 3.14, result['float_value']
    assert_equal true, result['boolean_true']
    assert_equal false, result['boolean_false']
    assert_equal true, result['boolean_yes']
    assert_equal false, result['boolean_no']
    assert_equal true, result['boolean_on']
    assert_equal false, result['boolean_off']
    assert_equal true, result['boolean_1']
    assert_equal false, result['boolean_0']
  end

  def test_ini_parser_comments
    content = <<~INI
      # Hash comment
      ; Semicolon comment
      key1=value1
      
      [section]
      # Section comment
      ; Another section comment
      key2=value2
    INI
    
    file_path = create_temp_file(content, '.ini')
    result = ConfigFiles::Loaders::Ini.call(file_path)
    
    assert_equal 'value1', result['key1']
    assert_equal 'value2', result['section']['key2']
  end

  # XML Parser Tests
  def test_xml_parser_basic_structure
    content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <config>
        <key1>value1</key1>
        <key2>value2</key2>
      </config>
    XML
    
    file_path = create_temp_file(content, '.xml')
    result = ConfigFiles::Loaders::Xml.call(file_path)
    
    assert_equal 'value1', result['key1']
    assert_equal 'value2', result['key2']
  end

  def test_xml_parser_nested_elements
    content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <config>
        <database>
          <host>localhost</host>
          <port>5432</port>
        </database>
        <app>
          <name>Test App</name>
          <debug>true</debug>
        </app>
      </config>
    XML
    
    file_path = create_temp_file(content, '.xml')
    result = ConfigFiles::Loaders::Xml.call(file_path)
    
    assert_equal 'localhost', result['database']['host']
    assert_equal 5432, result['database']['port']
    assert_equal 'Test App', result['app']['name']
    assert_equal true, result['app']['debug']
  end

  def test_xml_parser_attributes
    content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <config>
        <app name="Test App" version="1.0">
          <debug>false</debug>
        </app>
      </config>
    XML
    
    file_path = create_temp_file(content, '.xml')
    result = ConfigFiles::Loaders::Xml.call(file_path)
    
    assert_equal 'Test App', result['app']['@name']
    assert_equal 1.0, result['app']['@version']
    assert_equal false, result['app']['debug']
  end

  def test_xml_parser_multiple_elements_same_name
    content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <config>
        <item>value1</item>
        <item>value2</item>
        <item>value3</item>
      </config>
    XML
    
    file_path = create_temp_file(content, '.xml')
    result = ConfigFiles::Loaders::Xml.call(file_path)
    
    assert result['item'].is_a?(Array)
    assert_equal 3, result['item'].length
    assert_equal 'value1', result['item'][0]
    assert_equal 'value2', result['item'][1]
    assert_equal 'value3', result['item'][2]
  end

  def test_xml_parser_value_types
    content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <config>
        <string_value>hello world</string_value>
        <integer_value>42</integer_value>
        <float_value>3.14</float_value>
        <boolean_true>true</boolean_true>
        <boolean_false>false</boolean_false>
        <empty_value></empty_value>
      </config>
    XML
    
    file_path = create_temp_file(content, '.xml')
    result = ConfigFiles::Loaders::Xml.call(file_path)
    
    assert_equal 'hello world', result['string_value']
    assert_equal 42, result['integer_value']
    assert_equal 3.14, result['float_value']
    assert_equal true, result['boolean_true']
    assert_equal false, result['boolean_false']
    assert_nil result['empty_value']
  end

  # Test existing dummy files to ensure compatibility
  def test_existing_dummy_files
    conf_result = ConfigFiles::Loaders::Conf.call('test/etc/dummy.conf')
    ini_result = ConfigFiles::Loaders::Ini.call('test/etc/dummy.ini')
    xml_result = ConfigFiles::Loaders::Xml.call('test/etc/dummy.xml')
    
    # CONF file assertions
    assert_equal 'test2', conf_result['config_test']
    assert_equal 'conf_file', conf_result['only_in_conf']
    assert_equal 'myserver', conf_result['server']['name']
    assert_equal 'nested_value', conf_result['nested']['config']['value']
    assert_equal 'conf-db.example.com', conf_result['database']['host']
    assert_equal 5433, conf_result['database']['port']
    assert_equal true, conf_result['database']['ssl']
    assert_equal 'CONF App', conf_result['app']['name']
    assert_equal false, conf_result['app']['debug']
    
    # INI file assertions
    assert_equal 'ini_value', ini_result['global_setting']
    assert_equal 'ini-db.example.com', ini_result['database']['host']
    assert_equal 3306, ini_result['database']['port']
    assert_equal true, ini_result['database']['ssl']
    assert_equal 'INI App', ini_result['app']['name']
    assert_equal false, ini_result['app']['debug']
    assert_equal 2.0, ini_result['app']['version']
    
    # XML file assertions
    assert_equal 'xml_value', xml_result['global_setting']
    assert_equal 'xml-db.example.com', xml_result['database']['host']
    assert_equal 5432, xml_result['database']['port']
    assert_equal true, xml_result['database']['ssl']
    assert_equal 'XML App', xml_result['app']['@name']
    assert_equal false, xml_result['app']['debug']
    assert_equal 3.0, xml_result['app']['version']
  end
end