#!/bin/bash

# Script to test multiple Ruby versions using Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ruby versions to test
RUBY_VERSIONS=("2.7" "3.0" "3.1" "3.2" "3.3" "3.4")

# ActiveSupport versions to test
ACTIVESUPPORT_VERSIONS=("~> 6.1.0" "~> 7.0.0" "~> 7.1.0" "~> 7.2.0")

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
    
    # Build and run Docker container
    if docker build \
        --build-arg RUBY_VERSION="$ruby_version" \
        --build-arg ACTIVESUPPORT_VERSION="$activesupport_version" \
        -f docker/Dockerfile.test \
        -t "config_files_test:ruby${ruby_version}-as${activesupport_version//[~>. ]/}" \
        . && \
       docker run --rm "config_files_test:ruby${ruby_version}-as${activesupport_version//[~>. ]/}"; then
        echo -e "${GREEN}✓ Ruby ${ruby_version} with ActiveSupport ${activesupport_version} - PASSED${NC}"
        return 0
    else
        echo -e "${RED}✗ Ruby ${ruby_version} with ActiveSupport ${activesupport_version} - FAILED${NC}"
        return 1
    fi
}

# Main execution
echo -e "${YELLOW}Starting Docker-based multi-Ruby testing...${NC}"

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}Docker not found. Please install Docker to use this script.${NC}"
    exit 1
fi

failed_combinations=()
total_tests=0
passed_tests=0

for ruby_version in "${RUBY_VERSIONS[@]}"; do
    for activesupport_version in "${ACTIVESUPPORT_VERSIONS[@]}"; do
        total_tests=$((total_tests + 1))
        
        if test_combination "$ruby_version" "$activesupport_version"; then
            passed_tests=$((passed_tests + 1))
        else
            failed_combinations+=("Ruby ${ruby_version} + ActiveSupport ${activesupport_version}")
        fi
    done
done

# Clean up Docker images
echo -e "\n${YELLOW}Cleaning up Docker images...${NC}"
docker images --format "table {{.Repository}}:{{.Tag}}" | grep "config_files_test" | xargs -r docker rmi

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