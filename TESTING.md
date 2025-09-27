# Testing ConfigFiles

This document describes how to test the ConfigFiles gem across multiple Ruby versions and ActiveSupport versions.

## Supported Versions

### Ruby Versions
- **Ruby 2.7+**: Full support with ActiveSupport 6.1+ and 7.0+
- **Ruby 3.0+**: Full support with all ActiveSupport versions
- **Ruby 3.1+**: Full support with all ActiveSupport versions including 7.1+ and 7.2+

### ActiveSupport Versions
- **ActiveSupport 6.1**: Compatible with Ruby 2.7+
- **ActiveSupport 7.0**: Compatible with Ruby 2.7+
- **ActiveSupport 7.1**: Compatible with Ruby 3.1+
- **ActiveSupport 7.2**: Compatible with Ruby 3.1+

## Testing Methods

### 1. GitHub Actions (Recommended for CI/CD)

The project uses GitHub Actions for automated testing across multiple Ruby and ActiveSupport versions.

**Configuration**: `.github/workflows/ci.yml`

**Features**:
- Tests Ruby 2.7, 3.0, 3.1, 3.2, 3.3, and 3.4
- Tests ActiveSupport 6.1, 7.0, 7.1, and 7.2
- Automatically excludes incompatible combinations
- Includes linting with RuboCop
- Runs on every push and pull request

### 2. Local Testing with Multiple Ruby Versions

#### Using Multi-Manager Script (asdf/rbenv/rvm)

```bash
# The script automatically detects which Ruby version manager you have installed:
# - asdf (recommended)
# - rbenv 
# - rvm

# Install Ruby versions (choose your manager):
# asdf: ./scripts/install_rubies_asdf.sh
# rbenv: rbenv install 2.7.8 3.0.6 3.1.4 3.2.2 3.3.0 3.4.1
# rvm: rvm install 2.7.8 3.0.6 3.1.4 3.2.2 3.3.0 3.4.1

# Run the multi-Ruby test script
./scripts/test_multiple_rubies.sh
```

This script will:
- Auto-detect your Ruby version manager (asdf, rbenv, or rvm)
- Check which Ruby versions are installed
- Offer to install missing Ruby versions
- Test each Ruby version with multiple ActiveSupport versions
- Skip incompatible combinations
- Provide a summary of results

#### asdf-Specific Installation

```bash
# Install all Ruby versions at once with asdf
./scripts/install_rubies_asdf.sh

# Then run tests
./scripts/test_multiple_rubies.sh
```

#### Using Docker

```bash
# Test all combinations using Docker
./scripts/test_docker.sh

# Test a specific Ruby version
docker build --build-arg RUBY_VERSION=3.3 --build-arg ACTIVESUPPORT_VERSION="~> 7.0" -f docker/Dockerfile.test -t config_files_test .
docker run --rm config_files_test
```

### 3. Single Version Testing

#### Standard Testing
```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rake test

# Run tests with verbose output
bundle exec rake test_verbose

# Run individual test files
find test -name "*_test.rb" -exec bundle exec ruby {} \;
```

#### Testing with Specific ActiveSupport Version
```bash
# Create a custom Gemfile
cat > Gemfile.custom << EOF
source 'https://rubygems.org'
gemspec
gem 'activesupport', '~> 6.1.0'
gem 'minitest', '~> 5.20'
gem 'rake'
EOF

# Install and test
BUNDLE_GEMFILE=Gemfile.custom bundle install
BUNDLE_GEMFILE=Gemfile.custom bundle exec rake test
```

## Test Structure

### Test Files
- `test/config_files_test.rb` - Core functionality tests
- `test/loader_factory_test.rb` - File loader tests
- `test/multi_directory_test.rb` - Multi-directory functionality
- `test/mixed_format_test.rb` - Mixed YAML/JSON format tests
- `test/comprehensive_multi_directory_test.rb` - Complex scenarios

### Test Data
- `test/etc/` - Sample configuration files
- `test/config/` - Additional test configurations
- `test/local/` - Local override test files

## Compatibility Testing

### Ruby Version Compatibility

The gem uses these Ruby features that affect compatibility:

1. **Safe Navigation Operator (`&.`)** - Requires Ruby 2.3+
2. **Keyword Arguments** - Requires Ruby 2.0+
3. **ActiveSupport Dependencies** - Varies by version

### ActiveSupport Compatibility

Different ActiveSupport versions have different Ruby requirements:

- ActiveSupport 5.2: Ruby 2.2.2+
- ActiveSupport 6.0: Ruby 2.5.0+
- ActiveSupport 6.1: Ruby 2.5.0+
- ActiveSupport 7.0: Ruby 2.7.0+
- ActiveSupport 7.1: Ruby 3.1.0+
- ActiveSupport 7.2: Ruby 3.1.0+

## Troubleshooting

### Common Issues

1. **Safe Navigation Operator Error**
   ```
   undefined method `&' for nil:NilClass
   ```
   **Solution**: Use Ruby 2.3+ or replace `&.` with `&& obj.`

2. **ActiveSupport Version Conflicts**
   ```
   Gem::ConflictError: Unable to activate activesupport
   ```
   **Solution**: Check Ruby/ActiveSupport compatibility matrix above

3. **Minitest Version Issues**
   ```
   cannot load such file -- mutex_m
   ```
   **Solution**: Add `mutex_m` gem for Ruby 3.4+

### Running Specific Test Combinations

```bash
# Test Ruby 3.3 with ActiveSupport 7.0
RUBY_VERSION=3.3 ACTIVESUPPORT_VERSION="~> 7.0" ./scripts/test_combination.sh

# Test with Docker
docker build --build-arg RUBY_VERSION=3.3 --build-arg ACTIVESUPPORT_VERSION="~> 7.0" -f docker/Dockerfile.test -t test .
docker run --rm test
```

## CI/CD Integration

### GitHub Actions

The project automatically tests all supported combinations on:
- Push to main/master branch
- Pull requests
- Manual workflow dispatch

### Other CI Systems

The testing approach can be adapted for other CI systems:

- **GitLab CI**: Use similar matrix strategy with `.gitlab-ci.yml`
- **CircleCI**: Use workflow matrix with different Ruby Docker images
- **Jenkins**: Use pipeline with multiple Ruby environments

## Performance Testing

For performance testing across versions:

```bash
# Run benchmarks (if implemented)
bundle exec rake benchmark

# Memory usage testing
bundle exec ruby -r memory_profiler test/memory_test.rb
```

## Contributing

When adding new features:

1. Ensure tests pass on all supported Ruby versions
2. Add tests for new functionality
3. Update compatibility documentation if needed
4. Run the full test matrix before submitting PRs

```bash
# Quick local test
bundle exec rake test

# Full compatibility test
./scripts/test_multiple_rubies.sh
```