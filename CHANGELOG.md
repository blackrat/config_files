# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2024-12-26

### Added
- Multi-directory configuration support - load and merge configs from multiple directories
- Directory precedence system - earlier directories override later ones
- Mixed file format support - YAML, JSON, and other formats in the same project
- Deep merging of nested configuration structures
- Comprehensive test suite with multi-Ruby version support (2.7-3.4)
- GitHub Actions CI/CD pipeline
- Support for asdf, rbenv, and rvm version managers
- Docker-based testing environment
- Extensive documentation and examples

### Changed
- **BREAKING**: Directory precedence now works correctly - first directory wins
- Ruby version requirement updated to >= 2.7.0
- ActiveSupport dependency updated to >= 6.1, < 8.0
- Improved error handling for missing directories and files
- Updated development dependencies (minitest ~> 5.20, mutex_m for Ruby 3.4+)

### Fixed
- Safe navigation operator compatibility with older Ruby versions
- Minitest constant name (MiniTest -> Minitest)
- File processing order within directories (alphabetical)

## [0.1.7] - 2023-01-15

### Added
- HashWithIndifferentAccess support for consistent key access with strings and symbols

### Changed
- Configuration hashes now return HashWithIndifferentAccess instead of regular Hash
- Improved key access flexibility

## [0.1.6] - 2022-12-10

### Added
- Default directory support - directories are used even if not explicitly declared
- Better handling of missing configuration scenarios

### Fixed
- Empty file handling improvements
- Default directory initialization

## [0.1.5] - 2022-11-20

### Added
- 'config' directory added to default :etc directory list
- Improved empty file and missing file handling

### Fixed
- Better error handling for non-existent configuration files
- More robust directory scanning

## [0.1.3] - 2022-10-15

### Fixed
- JSON.load now properly receives an IO object instead of filename
- Improved JSON file parsing reliability

## [0.1.2] - 2022-09-28

### Changed
- JSON parsing now uses quirks mode for better compatibility
- More flexible JSON file format support

## [0.1.1] - 2022-09-20

### Changed
- Configuration objects now return Hash instead of OpenStruct
- Simplified data structure for better performance and compatibility

## [0.1.0] - 2022-09-15

### Added
- Initial release
- Basic YAML configuration file loading
- Single directory support
- Static and dynamic configuration file loading
- Support for multiple file extensions (.yml, .json, .conf)
- File-based configuration discovery
- Basic directory searching functionality

### Features
- `config_directories` method to define search paths
- `static_config_files` for cached configuration loading
- `dynamic_config_files` for real-time configuration reloading
- Automatic file extension detection and parsing
- Integration with ActiveSupport for deep merging capabilities

---

## Migration Guide

### Upgrading from 0.1.x to 0.2.0

The major change in 0.2.0 is the addition of multi-directory support and corrected directory precedence.

#### Before (0.1.x)
```ruby
class MyApp
  include ConfigFiles
  config_directories etc: ['/etc/myapp']  # Single directory
  static_config_files :config
end
```

#### After (0.2.0)
```ruby
class MyApp
  include ConfigFiles
  config_directories etc: [
    'config/production',  # Highest priority
    'config/defaults'     # Fallback values
  ]
  static_config_files :config
end
```

#### Key Changes
1. **Multi-directory support**: You can now specify multiple directories
2. **Directory precedence**: Earlier directories in the list override later ones
3. **Deep merging**: Configurations from all directories are intelligently merged
4. **Mixed formats**: YAML and JSON files can coexist and are merged together

#### Compatibility
- Single directory configurations continue to work unchanged
- Existing method signatures are preserved
- Return values maintain the same structure (HashWithIndifferentAccess)

## Development

### Version History Summary
- **0.1.x series**: Basic single-directory YAML configuration loading
- **0.2.0**: Major enhancement with multi-directory support and mixed formats

### Contributors
- Paul McKibbin - Original author and maintainer

### License
MIT License - see [LICENCE.txt](LICENCE.txt) for details.