#!/usr/bin/env bash  
# Exit on error, unset vars, and pipeline failures, like strict mode in JS
set -euo pipefail

MIN_COVERAGE=70

check_coverage() {
    echo "🧪 Checking test coverage..."

    # Get the coverage number from the output of sui move coverage summary
    local coverage=$(sui move coverage summary | awk '/Move Coverage:/ {print $5}')

    # Check if the coverage is greater than or equal to the minimum required
    # Awk returns 0 if the condition is false, so we check if the result is not 0
    
    # Compare values using AWK
    awk -v cov="$coverage" -v min="$MIN_COVERAGE" '
        BEGIN {

            if (cov >= 90 ) {
                printf "%s🌟 Excellent coverage: %.1f%% (Minimum: %d%%)%s\n", 
                green, cov, min, nc
            } else if (cov >= 80) {
                printf "%s✨ Good coverage: %.1f%% (Minimum: %d%%)%s\n", 
                yellow, cov, min, nc
            } if (cov >= min) {
                printf "✅ Coverage: %.1f%% (Minimum: %d%%)\n", cov, min
                exit 0
            } else if (cov == "" || cov !~ /^[0-9]+(\.[0-9]+)?$/ ) {
                print "❌ Error: Coverage not found"
                exit 2
            } else {
                printf "❌ Coverage failed: %.1f%% < %d%%\n", cov, min
                exit 1
            }
        }'
    exit $?
}