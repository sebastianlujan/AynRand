#!/usr/bin/env bash  
set -euo pipefail

# Color definitions
YELLOW='\033[1;33m'
NC='\033[0m'

check_testing() {
    echo "🧪 Checking tests..."
    
    # Run the tests and capture the output
    test_output=$(sui move test --coverage 2>&1)
    exit_code=$?

    if echo "$test_output" | grep -q "FAIL"; then
        echo "❌ Test failed"
        exit 1
    fi

    # Check if the tests passed 
    if [ $exit_code -ne 0 ]; then
        echo "❌ Test execution failed $exit_code"
        exit $exit_code
    fi

    echo "✅ All tests passed"

    echo "$test_output" | awk '/Test result:/ {
        sub(/OK/, "'${YELLOW}'OK'${NC}'");
        print
    '}
    exit 0
}