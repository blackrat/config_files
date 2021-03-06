*Description*

Since it no longer just deals with yaml files as an input, *blackrat_yaml_config* has been renamed to *config_files*
Configuration file manager.

*Features*

Searches for first match in multiple directories for configuration file
Allows for dynamically updated or static config files

*Example*

    require 'config_files'

    class Dummy
      include ConfigFiles #mixin the config_directories and config_files generators

      #search directories (in order). The system will search for the file in the following directories
      config_directories :etc=>['~/.dummy','/opt/dummy/config','/etc/default/dummy','/etc']

      #The dummy.yml and another_yaml_file.yml will be pre-loaded.
      static_config_files :dummy, :another_yaml_file

      #yet_another_yaml_file.yml will be read every time the .yet_another_yaml_file method is accessed.
      dynamic_config_files :yet_another_yaml_file

      def use_config
        some_method(Dummy.dummy[:key]) #extract the constant values from the :key in dummy.yml
        another_method(Dummy.yet_another_yaml_file[:another_key]) #extract the constant value from the :another_key in yet_another_yaml_file.yml
      end

    end



*Todo*

Allow for different keys to be stored in files in different subdirectories to allow for overridable defaults
