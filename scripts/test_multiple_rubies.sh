#!/bin/bash

# Script to test multiple Ruby versions locally
# Supports asdf, rbenv, and rvm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ruby versions to test
RUBY_VERSIONS=("2.7.8" "3.0.6" "3.1.4" "3.2.2" "3.3.0" "3.4.1")

# ActiveSupport versions to test
ACTIVESUPPORT_VERSIONS=("~> 6.1.0" "~> 7.0.0" "~> 7.1.0" "~> 7.2.0")

# Detect which Ruby version manager is available
RUBY_MANAGER=""

detect_ruby_manager() {
    if command -v asdf >/dev/null 2>&1; then
        RUBY_MANAGER="asdf"
        echo -e "${BLUE}Detected asdf${NC}"
    elif command -v rbenv >/dev/null 2>&1; then
        RUBY_MANAGER="rbenv"
        echo -e "${BLUE}Detected rbenv${NC}"
    elif command -v rvm >/dev/null 2>&1; then
        RUBY_MANAGER="rvm"
        echo -e "${BLUE}Detected rvm${NC}"
    else
        echo -e "${RED}No Ruby version manager found!${NC}"
        echo -e "${YELLOW}Please install one of the following:${NC}"
        echo -e "  - asdf: https://asdf-vm.com/guide/getting-started.html"
        echo -e "  - rbenv: https://github.com/rbenv/rbenv#installation"
        echo -e "  - rvm: https://rvm.io/rvm/install"
        exit 1
    fi
}

# Function to check if Ruby version is installed
check_ruby_version() {
    local version=$1
    case $RUBY_MANAGER in
        "asdf")
            asdf list ruby 2>/dev/null | grep -q "^\s*${version}$"
            ;;
        "rbenv")
            rbenv versions --bare | grep -q "^${version}$"
            ;;
        "rvm")
            rvm list | grep -q "${version}"
            ;;
    esac
}

# Function to install Ruby version if not present
install_ruby_version() {
    local version=$1
    echo -e "${YELLOW}Installing Ruby ${version} with ${RUBY_MANAGER}...${NC}"
    
    case $RUBY_MANAGER in
        "asdf")
            # Check if ruby plugin is installed
            if ! asdf plugin list | grep -q "^ruby$"; then
                echo -e "${YELLOW}Installing Ruby plugin for asdf...${NC}"
                asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
            fi
            asdf install ruby "$version"
            ;;
        "rbenv")
            rbenv install "$version"
            ;;
        "rvm")
            rvm install "$version"
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Ruby ${version} installed successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to install Ruby ${version}${NC}"
        return 1
    fi
}

# Function to switch Ruby version
switch_ruby() {
    local version=$1
    
    case $RUBY_MANAGER in
        "asdf")
            asdf local ruby "$version"
            # Verify the switch worked
            local current_version
            current_version=$(asdf current ruby 2>/dev/null | awk '{print $2}')
            if [[ "$current_version" != "$version" ]]; then
                echo -e "${RED}Failed to switch to Ruby ${version}. Current: ${current_version}${NC}"
                return 1
            fi
            ;;
        "rbenv")
            rbenv shell "$version"
            # Verify the switch worked
            local current_version
            current_version=$(rbenv version-name)
            if [[ "$current_version" != "$version" ]]; then
                echo -e "${RED}Failed to switch to Ruby ${version}. Current: ${current_version}${NC}"
                return 1
            fi
            ;;
        "rvm")
            rvm use "$version"
            # rvm use typically handles verification internally
            ;;
    esac
    
    echo -e "${BLUE}Switched to Ruby ${version} using ${RUBY_MANAGER}${NC}"
    return 0
}

# Function to list available Ruby versions
list_available_versions() {
    echo -e "\n${BLUE}Available Ruby versions:${NC}"
    case $RUBY_MANAGER in
        "asdf")
            asdf list ruby 2>/dev/null || echo "  No Ruby versions installed"
            ;;
        "rbenv")
            rbenv versions --bare || echo "  No Ruby versions installed"
            ;;
        "rvm")
            rvm list || echo "  No Ruby versions installed"
            ;;
    esac
}

# Function to test a specific Ruby and ActiveSupport combination
test_combination() {
    local ruby_version=$1
    local activesupport_version=$2
    
    echo -e "${YELLOW}Testing Ruby ${ruby_version} with ActiveSupport ${activesupport_version}${NC}"
    
    # Skip incompatible combinations
    if [[ "$ruby_version" =~ ^2\.[67] ]] && [[ "$activesupport_version" =~ 7\.[12] ]]; then
        echo -e "${YELLOW}Skipping incompatible combination${NC}"
        return 0
    fi
    
    # Create temporary Gemfile
    cat > Gemfile.test << EOF
source 'https://rubygems.org'

gemspec

gem 'activesupport', '${activesupport_version}'
gem 'minitest', '~> 5.20'
gem 'mutex_m' if RUBY_VERSION >= '3.4'
gem 'rake'
EOF

    # Install dependencies and run tests
    if bundle install --gemfile=Gemfile.test && BUNDLE_GEMFILE=Gemfile.test bundle exec rake test; then
        echo -e "${GREEN}✓ Ruby ${ruby_version} with ActiveSupport ${activesupport_version} - PASSED${NC}"
        return 0
    else
        echo -e "${RED}✗ Ruby ${ruby_version} with ActiveSupport ${activesupport_version} - FAILED${NC}"
        return 1
    fi
}

# Handle command line arguments
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo -e "${BLUE}ConfigFiles Multi-Ruby Testing Script${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo
    echo -e "${YELLOW}Usage:${NC} $0 [options]"
    echo
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -h, --help     Show this help message"
    echo -e "  --list         List available Ruby versions and exit"
    echo -e "  --auto-install Automatically install missing Ruby versions without prompting"
    echo
    echo -e "${YELLOW}Supported Ruby Version Managers:${NC}"
    echo -e "  - asdf (recommended)"
    echo -e "  - rbenv"
    echo -e "  - rvm"
    echo
    echo -e "${YELLOW}Ruby Versions Tested:${NC}"
    for version in "${RUBY_VERSIONS[@]}"; do
        echo -e "  - Ruby ${version}"
    done
    echo
    echo -e "${YELLOW}ActiveSupport Versions Tested:${NC}"
    for version in "${ACTIVESUPPORT_VERSIONS[@]}"; do
        echo -e "  - ActiveSupport ${version}"
    done
    echo
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0                    # Run interactive testing"
    echo -e "  $0 --list             # Show available Ruby versions"
    echo -e "  $0 --auto-install     # Install missing versions automatically"
    exit 0
fi

# Main execution
echo -e "${YELLOW}Starting multi-Ruby testing...${NC}"

# Detect Ruby version manager
detect_ruby_manager

# Show available versions
list_available_versions

failed_combinations=()
total_tests=0
passed_tests=0
installed_versions=()

# Check and install Ruby versions
echo -e "\n${BLUE}Checking required Ruby versions...${NC}"
for ruby_version in "${RUBY_VERSIONS[@]}"; do
    if check_ruby_version "$ruby_version"; then
        echo -e "${GREEN}✓ Ruby ${ruby_version} is already installed${NC}"
        installed_versions+=("$ruby_version")
    else
        echo -e "${YELLOW}Ruby ${ruby_version} not found${NC}"
        read -p "Install Ruby ${ruby_version}? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if install_ruby_version "$ruby_version"; then
                installed_versions+=("$ruby_version")
            else
                echo -e "${RED}Skipping Ruby ${ruby_version} due to installation failure${NC}"
            fi
        else
            echo -e "${YELLOW}Skipping Ruby ${ruby_version}${NC}"
        fi
    fi
done

if [ ${#installed_versions[@]} -eq 0 ]; then
    echo -e "${RED}No Ruby versions available for testing. Exiting.${NC}"
    exit 1
fi

echo -e "\n${BLUE}Testing with ${#installed_versions[@]} Ruby versions...${NC}"

for ruby_version in "${installed_versions[@]}"; do
    echo -e "\n${YELLOW}=== Testing Ruby ${ruby_version} ===${NC}"
    
    if ! switch_ruby "$ruby_version"; then
        echo -e "${RED}Failed to switch to Ruby ${ruby_version}. Skipping.${NC}"
        continue
    fi
    
    for activesupport_version in "${ACTIVESUPPORT_VERSIONS[@]}"; do
        total_tests=$((total_tests + 1))
        
        if test_combination "$ruby_version" "$activesupport_version"; then
            passed_tests=$((passed_tests + 1))
        else
            failed_combinations+=("Ruby ${ruby_version} + ActiveSupport ${activesupport_version}")
        fi
        
        # Clean up
        rm -f Gemfile.test Gemfile.test.lock
    done
done

# Summary
echo -e "\n${YELLOW}=== Test Summary ===${NC}"
echo -e "Total combinations tested: ${total_tests}"
echo -e "${GREEN}Passed: ${passed_tests}${NC}"
echo -e "${RED}Failed: $((total_tests - passed_tests))${NC}"

if [ ${#failed_combinations[@]} -gt 0 ]; then
    echo -e "\n${RED}Failed combinations:${NC}"
    for combination in "${failed_combinations[@]}"; do
        echo -e "${RED}  - ${combination}${NC}"
    done
    exit 1
else
    echo -e "\n${GREEN}All tests passed! 🎉${NC}"
fi