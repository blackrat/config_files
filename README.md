# ConfigFiles

[![CI](https://github.com/blackrat/config_files/workflows/CI/badge.svg)](https://github.com/blackrat/config_files/actions)
[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%202.7.0-ruby.svg)](https://www.ruby-lang.org/en/downloads/)
[![Gem Version](https://badge.fury.io/rb/config_files.svg)](https://badge.fury.io/rb/config_files)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Load configuration files from multiple directories and merge them together. Supports YAML, JSON, and other formats.

## Features

- Load configs from multiple directories
- Merge YAML, JSON, and other file formats
- Directory precedence (first directory wins)
- Static (cached) or dynamic (reloaded) config files
- Returns `HashWithIndifferentAccess` for easy key access

## Installation

Add to your Gemfile:

```ruby
gem 'config_files'
```

Or install it:

```bash
gem install config_files
```

## Usage

```ruby
require 'config_files'

class MyApp
  include ConfigFiles
  
  # Search these directories in order (first wins)
  config_directories etc: [
    'config/production',
    'config/staging',
    'config/defaults'
  ]
  
  # Load these config files
  static_config_files :database, :app_settings
  dynamic_config_files :feature_flags
end

# Use the configs
MyApp.database[:host]           # => "prod-db.example.com"
MyApp.app_settings[:debug]      # => false
MyApp.feature_flags[:new_ui]    # => true (reloaded each time)
```

## How it works

The gem searches for config files in each directory you specify. If you have:

```
config/production/database.yml
config/staging/database.yml
config/defaults/database.yml
```

And you configure directories as `['config/production', 'config/staging', 'config/defaults']`, then:

1. It loads all three files
2. Merges them together
3. Values from `production` override `staging` and `defaults`
4. Values from `staging` override `defaults`
5. Returns the merged result

## Multiple file formats

You can mix YAML and JSON files:

```
config/
├── app.yml     # YAML format
├── app.json    # JSON format
└── app.conf    # Other formats
```

All files with the same base name get merged together. Files are processed alphabetically, so `app.json` loads before `app.yml`.

## Static vs Dynamic

```ruby
class AppConfig
  include ConfigFiles
  config_directories etc: ['config']
  
  # Static: loaded once and cached
  static_config_files :database
  
  # Dynamic: reloaded from disk each time
  dynamic_config_files :feature_flags
end

AppConfig.database        # Fast (cached)
AppConfig.feature_flags   # Slower (reads from disk)
```

Use static for configs that don't change. Use dynamic for configs that might change while your app is running.

## Directory precedence

Earlier directories in the list win:

```ruby
config_directories etc: [
  'config/production',   # Highest priority
  'config/staging',      # Medium priority
  'config/defaults'      # Lowest priority
]
```

So if `production/app.yml` has `debug: false` and `defaults/app.yml` has `debug: true`, the result will have `debug: false`.

## Configuration merging

Configs are deep-merged. Given these files:

```yaml
# config/defaults/app.yml
database:
  host: localhost
  port: 5432
  pool_size: 5
app:
  debug: true
  name: MyApp
```

```yaml
# config/production/app.yml
database:
  host: prod-db.example.com
  pool_size: 20
app:
  debug: false
```

The result is:

```ruby
{
  database: {
    host: "prod-db.example.com",  # from production
    port: 5432,                   # from defaults
    pool_size: 20                 # from production
  },
  app: {
    debug: false,                 # from production
    name: "MyApp"                 # from defaults
  }
}
```

## Custom directory keys

You can use different directory sets:

```ruby
class AppConfig
  include ConfigFiles
  
  config_directories(
    etc: ['config/app', '/etc/myapp'],
    secrets: ['secrets/production', 'secrets/shared']
  )
  
  static_config_files :database    # searches in 'etc' directories
end

# Access the directory paths
AppConfig.etc_dir      # => ["/full/path/to/config/app", "/etc/myapp"]
AppConfig.secrets_dir  # => ["/full/path/to/secrets/production", ...]
```

## Error handling

Missing files and directories are ignored:

```ruby
class AppConfig
  include ConfigFiles
  
  config_directories etc: [
    'config/nonexistent',  # ignored
    'config/existing'      # used
  ]
  
  static_config_files :missing_file
end

AppConfig.missing_file  # => {} (empty hash)
```

## Testing

Run the tests:

```bash
bundle exec rake test
```

Test with multiple Ruby versions:

```bash
./scripts/test_multiple_rubies.sh
```

The gem is tested on Ruby 2.7+ with ActiveSupport 6.1+. See [TESTING.md](TESTING.md) for details.

## API

### config_directories(hash)

Define search directories:

```ruby
config_directories etc: ['dir1', 'dir2']
```

### static_config_files(*files)

Load files once and cache them:

```ruby
static_config_files :database, :app_settings
```

### dynamic_config_files(*files)

Reload files on each access:

```ruby
dynamic_config_files :feature_flags
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-feature`)
3. Make your changes
4. Run the tests (`bundle exec rake test`)
5. Commit your changes (`git commit -am 'Add feature'`)
6. Push to the branch (`git push origin my-feature`)
7. Create a Pull Request

## License

MIT License. See [LICENCE.txt](LICENCE.txt) for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.