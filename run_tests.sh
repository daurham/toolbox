#!/usr/bin/env bash

# Simple test runner for toolbox
# Usage: ./run_tests.sh

echo "🧪 Running Toolbox Test Suite"
echo "================================"

# Make test suite executable
chmod +x tests/test_suite.sh

# Run the test suite
./tests/test_suite.sh

# Exit with the same code as the test suite
exit $? 