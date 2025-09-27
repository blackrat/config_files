#!/bin/bash

# Script to install all Ruby versions needed for testing using asdf
# This is a specialized script for asdf users

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ruby versions to install
RUBY_VERSIONS=("2.7.8" "3.0.6" "3.1.4" "3.2.2" "3.3.0" "3.4.1")

echo -e "${BLUE}ConfigFiles Ruby Installation Script (asdf)${NC}"
echo -e "${BLUE}===========================================${NC}"

# Function to check if asdf is installed and configured
check_asdf() {
    if ! command -v asdf >/dev/null 2>&1; then
        echo -e "${RED}asdf not found. Please install asdf first.${NC}"
        echo -e "${BLUE}Installation instructions:${NC}"
        echo -e "  macOS: brew install asdf"
        echo -e "  Linux: git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0"
        echo -e "  More info: https://asdf-vm.com/guide/getting-started.html"
        exit 1
    fi
    
    echo -e "${GREEN}✓ asdf found${NC}"
    
    # Check if ruby plugin is installed
    if ! asdf plugin list | grep -q "^ruby$"; then
        echo -e "${YELLOW}Installing Ruby plugin...${NC}"
        if asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git; then
            echo -e "${GREEN}✓ Ruby plugin installed${NC}"
        else
            echo -e "${RED}✗ Failed to install Ruby plugin${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Ruby plugin already installed${NC}"
    fi
}

# Function to check if Ruby version is installed
check_ruby_version() {
    local version=$1
    asdf list ruby 2>/dev/null | grep -q "^\s*${version}$"
}

# Function to install Ruby version
install_ruby_version() {
    local version=$1
    echo -e "${YELLOW}Installing Ruby ${version}...${NC}"
    
    # Show progress
    if asdf install ruby "$version"; then
        echo -e "${GREEN}✓ Ruby ${version} installed successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to install Ruby ${version}${NC}"
        return 1
    fi
}

# Function to show system requirements
show_requirements() {
    echo -e "\n${BLUE}System Requirements:${NC}"
    echo -e "Before installing Ruby versions, make sure you have the required dependencies:"
    echo
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${YELLOW}macOS:${NC}"
        echo -e "  brew install openssl readline sqlite3 xz zlib"
        echo -e "  xcode-select --install"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${YELLOW}Ubuntu/Debian:${NC}"
        echo -e "  sudo apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev"
        echo -e "  sudo apt-get install -y libsqlite3-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev"
        echo -e "  sudo apt-get install -y libffi-dev libyaml-dev"
        echo
        echo -e "${YELLOW}CentOS/RHEL/Fedora:${NC}"
        echo -e "  sudo yum groupinstall -y 'Development Tools'"
        echo -e "  sudo yum install -y openssl-devel readline-devel zlib-devel sqlite-devel"
    fi
    
    echo
    read -p "Have you installed the required dependencies? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Please install the dependencies first, then run this script again.${NC}"
        exit 1
    fi
}

# Main execution
echo -e "\n${YELLOW}This script will install the following Ruby versions using asdf:${NC}"
for version in "${RUBY_VERSIONS[@]}"; do
    echo -e "  - Ruby ${version}"
done

echo
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation cancelled.${NC}"
    exit 0
fi

# Check asdf installation
check_asdf

# Show system requirements
show_requirements

# Check current installations
echo -e "\n${BLUE}Checking current Ruby installations...${NC}"
already_installed=()
to_install=()

for ruby_version in "${RUBY_VERSIONS[@]}"; do
    if check_ruby_version "$ruby_version"; then
        echo -e "${GREEN}✓ Ruby ${ruby_version} is already installed${NC}"
        already_installed+=("$ruby_version")
    else
        echo -e "${YELLOW}○ Ruby ${ruby_version} needs to be installed${NC}"
        to_install+=("$ruby_version")
    fi
done

if [ ${#to_install[@]} -eq 0 ]; then
    echo -e "\n${GREEN}All Ruby versions are already installed! 🎉${NC}"
    exit 0
fi

# Install missing versions
echo -e "\n${BLUE}Installing ${#to_install[@]} Ruby versions...${NC}"
failed_installations=()
successful_installations=()

for ruby_version in "${to_install[@]}"; do
    echo -e "\n${YELLOW}[$(date '+%H:%M:%S')] Installing Ruby ${ruby_version}...${NC}"
    
    if install_ruby_version "$ruby_version"; then
        successful_installations+=("$ruby_version")
    else
        failed_installations+=("$ruby_version")
        echo -e "${RED}Installation of Ruby ${ruby_version} failed. Continuing with others...${NC}"
    fi
done

# Summary
echo -e "\n${BLUE}=== Installation Summary ===${NC}"
echo -e "Already installed: ${#already_installed[@]}"
echo -e "${GREEN}Successfully installed: ${#successful_installations[@]}${NC}"
echo -e "${RED}Failed installations: ${#failed_installations[@]}${NC}"

if [ ${#successful_installations[@]} -gt 0 ]; then
    echo -e "\n${GREEN}Successfully installed:${NC}"
    for version in "${successful_installations[@]}"; do
        echo -e "${GREEN}  ✓ Ruby ${version}${NC}"
    done
fi

if [ ${#failed_installations[@]} -gt 0 ]; then
    echo -e "\n${RED}Failed installations:${NC}"
    for version in "${failed_installations[@]}"; do
        echo -e "${RED}  ✗ Ruby ${version}${NC}"
    done
    echo -e "\n${YELLOW}Troubleshooting tips:${NC}"
    echo -e "  1. Make sure you have all system dependencies installed"
    echo -e "  2. Check asdf ruby plugin: asdf plugin update ruby"
    echo -e "  3. Try installing manually: asdf install ruby <version>"
    echo -e "  4. Check logs in ~/.asdf/installs/ruby/<version>/install.log"
fi

# Show next steps
echo -e "\n${BLUE}Next Steps:${NC}"
echo -e "  1. Run the test suite: ./scripts/test_multiple_rubies.sh"
echo -e "  2. Set a global Ruby version: asdf global ruby <version>"
echo -e "  3. Set a local Ruby version: asdf local ruby <version>"

total_available=$((${#already_installed[@]} + ${#successful_installations[@]}))
echo -e "\n${GREEN}You now have ${total_available} Ruby versions available for testing! 🚀${NC}"