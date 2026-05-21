#!/bin/bash

# CV Intelligence Frontend Test Runner
# Comprehensive test suite for the EduCV CV Intelligence feature

set -e

echo "🧠 CV Intelligence Frontend Test Suite"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="test/features/cv_intelligence"
COVERAGE_DIR="coverage"

# Create coverage directory if it doesn't exist
mkdir -p $COVERAGE_DIR

echo -e "${BLUE}📋 Test Configuration${NC}"
echo "Test Directory: $TEST_DIR"
echo "Coverage Directory: $COVERAGE_DIR"
echo ""

# Function to run a specific test suite
run_test_suite() {
    local test_file=$1
    local test_name=$2
    
    echo -e "${YELLOW}🧪 Running $test_name${NC}"
    echo "----------------------------------------"
    
    if flutter test $test_file --coverage --reporter=expanded; then
        echo -e "${GREEN}✅ $test_name passed${NC}"
        return 0
    else
        echo -e "${RED}❌ $test_name failed${NC}"
        return 1
    fi
}

# Function to generate mock files
generate_mocks() {
    echo -e "${BLUE}🔧 Generating mock files${NC}"
    echo "----------------------------------------"
    
    # Generate mocks for CV Intelligence tests
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Mock files generated successfully${NC}"
    else
        echo -e "${RED}❌ Failed to generate mock files${NC}"
        exit 1
    fi
    echo ""
}

# Function to run all CV Intelligence tests
run_all_tests() {
    echo -e "${BLUE}🎯 Running All CV Intelligence Tests${NC}"
    echo "========================================"
    
    local failed_tests=()
    
    # Models Tests
    if ! run_test_suite "$TEST_DIR/models_test.dart" "Models Tests"; then
        failed_tests+=("Models Tests")
    fi
    echo ""
    
    # Repository Tests
    if ! run_test_suite "$TEST_DIR/repository_test.dart" "Repository Tests"; then
        failed_tests+=("Repository Tests")
    fi
    echo ""
    
    # Provider Tests
    if ! run_test_suite "$TEST_DIR/provider_test.dart" "Provider Tests"; then
        failed_tests+=("Provider Tests")
    fi
    echo ""
    
    # Widget Tests
    if ! run_test_suite "$TEST_DIR/widget_test.dart" "Widget Tests"; then
        failed_tests+=("Widget Tests")
    fi
    echo ""
    
    # Integration Tests
    if ! run_test_suite "$TEST_DIR/integration_test.dart" "Integration Tests"; then
        failed_tests+=("Integration Tests")
    fi
    echo ""
    
    # Summary
    echo -e "${BLUE}📊 Test Summary${NC}"
    echo "========================================"
    
    if [ ${#failed_tests[@]} -eq 0 ]; then
        echo -e "${GREEN}🎉 All CV Intelligence tests passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed test suites: ${failed_tests[*]}${NC}"
        return 1
    fi
}

# Function to generate coverage report
generate_coverage_report() {
    echo -e "${BLUE}📈 Generating Coverage Report${NC}"
    echo "----------------------------------------"
    
    # Generate LCOV report
    if command -v lcov &> /dev/null; then
        lcov --remove coverage/lcov.info \
            '*/test/*' \
            '*/generated/*' \
            '*/mocks/*' \
            '*/.dart_tool/*' \
            -o coverage/lcov_cleaned.info
        
        # Generate HTML report
        genhtml coverage/lcov_cleaned.info -o coverage/html
        
        echo -e "${GREEN}✅ Coverage report generated at coverage/html/index.html${NC}"
    else
        echo -e "${YELLOW}⚠️  lcov not installed. Coverage data available in coverage/lcov.info${NC}"
    fi
    echo ""
}

# Function to validate test quality
validate_test_quality() {
    echo -e "${BLUE}🔍 Validating Test Quality${NC}"
    echo "----------------------------------------"
    
    local test_files=("$TEST_DIR"/*.dart)
    local quality_issues=()
    
    for file in "${test_files[@]}"; do
        if [ -f "$file" ]; then
            # Check for test descriptions
            if ! grep -q "group\|testWidgets\|test" "$file"; then
                quality_issues+=("$file: No test cases found")
            fi
            
            # Check for assertions
            if ! grep -q "expect\|verify" "$file"; then
                quality_issues+=("$file: No assertions found")
            fi
            
            # Check for proper setup/teardown
            if grep -q "setUp\|tearDown" "$file"; then
                echo "✅ $(basename "$file"): Has proper setup/teardown"
            fi
        fi
    done
    
    if [ ${#quality_issues[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All tests meet quality standards${NC}"
    else
        echo -e "${YELLOW}⚠️  Quality issues found:${NC}"
        for issue in "${quality_issues[@]}"; do
            echo "  - $issue"
        done
    fi
    echo ""
}

# Function to check test coverage
check_coverage() {
    echo -e "${BLUE}📊 Checking Test Coverage${NC}"
    echo "----------------------------------------"
    
    if [ -f "coverage/lcov.info" ]; then
        # Calculate coverage percentage
        if command -v lcov &> /dev/null; then
            local coverage=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | grep -o '[0-9.]*%' | head -1)
            echo "Overall Coverage: $coverage"
            
            # Check if coverage meets minimum threshold (80%)
            local coverage_num=$(echo $coverage | sed 's/%//')
            if (( $(echo "$coverage_num >= 80" | bc -l) )); then
                echo -e "${GREEN}✅ Coverage meets minimum threshold (80%)${NC}"
            else
                echo -e "${YELLOW}⚠️  Coverage below minimum threshold (80%)${NC}"
            fi
        else
            echo "Coverage data available in coverage/lcov.info"
        fi
    else
        echo -e "${YELLOW}⚠️  No coverage data found${NC}"
    fi
    echo ""
}

# Function to run performance tests
run_performance_tests() {
    echo -e "${BLUE}⚡ Running Performance Tests${NC}"
    echo "----------------------------------------"
    
    # Test widget rendering performance
    flutter test --reporter=json $TEST_DIR/ > coverage/performance_report.json 2>/dev/null || true
    
    # Analyze test execution times
    if command -v jq &> /dev/null && [ -f "coverage/performance_report.json" ]; then
        echo "Test execution times:"
        jq -r '.[] | select(.type == "testDone") | "\(.test.name): \(.time)ms"' coverage/performance_report.json 2>/dev/null || echo "No performance data available"
    fi
    
    echo -e "${GREEN}✅ Performance tests completed${NC}"
    echo ""
}

# Main execution
main() {
    echo -e "${GREEN}🎯 EduCV CV Intelligence Test Suite${NC}"
    echo "======================================"
    echo ""
    
    # Generate mocks
    generate_mocks
    
    # Validate test quality
    validate_test_quality
    
    # Run all tests
    if run_all_tests; then
        # Generate coverage report
        generate_coverage_report
        
        # Check coverage
        check_coverage
        
        # Run performance tests
        run_performance_tests
        
        echo -e "${GREEN}🎉 All CV Intelligence tests completed successfully!${NC}"
        echo ""
        echo -e "${BLUE}📋 Next Steps:${NC}"
        echo "1. Review coverage report at coverage/html/index.html"
        echo "2. Check performance metrics in coverage/"
        echo "3. Ensure all tests pass in CI/CD pipeline"
        echo "4. Update documentation if needed"
        
        exit 0
    else
        echo -e "${RED}❌ Some tests failed. Please review and fix issues.${NC}"
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    "models")
        generate_mocks
        run_test_suite "$TEST_DIR/models_test.dart" "Models Tests"
        ;;
    "repository")
        generate_mocks
        run_test_suite "$TEST_DIR/repository_test.dart" "Repository Tests"
        ;;
    "provider")
        generate_mocks
        run_test_suite "$TEST_DIR/provider_test.dart" "Provider Tests"
        ;;
    "widget")
        run_test_suite "$TEST_DIR/widget_test.dart" "Widget Tests"
        ;;
    "integration")
        generate_mocks
        run_test_suite "$TEST_DIR/integration_test.dart" "Integration Tests"
        ;;
    "coverage")
        generate_coverage_report
        ;;
    "quality")
        validate_test_quality
        ;;
    *)
        main
        ;;
esac