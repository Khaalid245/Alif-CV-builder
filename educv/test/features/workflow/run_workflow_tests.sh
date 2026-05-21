#!/bin/bash

# Workflow Frontend Integration Test Runner
# Comprehensive test suite for the EduCV Workflow Control System

set -e

echo "🚀 Starting Workflow Frontend Integration Tests"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="test/features/workflow"
COVERAGE_DIR="coverage"
REPORTS_DIR="test_reports"

# Create directories if they don't exist
mkdir -p $COVERAGE_DIR
mkdir -p $REPORTS_DIR

echo -e "${BLUE}📋 Test Configuration${NC}"
echo "Test Directory: $TEST_DIR"
echo "Coverage Directory: $COVERAGE_DIR"
echo "Reports Directory: $REPORTS_DIR"
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
    
    # Generate mocks for workflow tests
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Mock files generated successfully${NC}"
    else
        echo -e "${RED}❌ Failed to generate mock files${NC}"
        exit 1
    fi
    echo ""
}

# Function to check test dependencies
check_dependencies() {
    echo -e "${BLUE}📦 Checking test dependencies${NC}"
    echo "----------------------------------------"
    
    # Check if required packages are installed
    local required_packages=("flutter_test" "mockito" "build_runner" "hooks_riverpod")
    local missing_packages=()
    
    for package in "${required_packages[@]}"; do
        if ! grep -q "$package:" pubspec.yaml; then
            missing_packages+=("$package")
        fi
    done
    
    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All required test dependencies are installed${NC}"
    else
        echo -e "${RED}❌ Missing test dependencies: ${missing_packages[*]}${NC}"
        echo "Please add the following to your pubspec.yaml dev_dependencies:"
        for package in "${missing_packages[@]}"; do
            echo "  $package: ^latest_version"
        done
        exit 1
    fi
    echo ""
}

# Function to run all workflow tests
run_all_tests() {
    echo -e "${BLUE}🎯 Running All Workflow Tests${NC}"
    echo "========================================"
    
    local failed_tests=()
    
    # Integration Tests
    if ! run_test_suite "$TEST_DIR/workflow_integration_test.dart" "Integration Tests"; then
        failed_tests+=("Integration Tests")
    fi
    echo ""
    
    # Provider Tests
    if ! run_test_suite "$TEST_DIR/workflow_provider_test.dart" "Provider Tests"; then
        failed_tests+=("Provider Tests")
    fi
    echo ""
    
    # Repository Tests
    if ! run_test_suite "$TEST_DIR/workflow_repository_test.dart" "Repository Tests"; then
        failed_tests+=("Repository Tests")
    fi
    echo ""
    
    # Widget Tests
    if ! run_test_suite "$TEST_DIR/workflow_widget_test.dart" "Widget Tests"; then
        failed_tests+=("Widget Tests")
    fi
    echo ""
    
    # Summary
    echo -e "${BLUE}📊 Test Summary${NC}"
    echo "========================================"
    
    if [ ${#failed_tests[@]} -eq 0 ]; then
        echo -e "${GREEN}🎉 All workflow tests passed!${NC}"
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
        echo -e "${YELLOW}⚠️  lcov not installed. Install with: sudo apt-get install lcov${NC}"
    fi
    echo ""
}

# Function to run performance tests
run_performance_tests() {
    echo -e "${BLUE}⚡ Running Performance Tests${NC}"
    echo "----------------------------------------"
    
    # Test widget rendering performance
    flutter test --reporter=json test/features/workflow/ > $REPORTS_DIR/performance_report.json
    
    # Analyze test execution times
    if command -v jq &> /dev/null; then
        echo "Test execution times:"
        jq -r '.[] | select(.type == "testDone") | "\(.test.name): \(.time)ms"' $REPORTS_DIR/performance_report.json
    fi
    
    echo -e "${GREEN}✅ Performance tests completed${NC}"
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

# Function to run integration with backend
test_backend_integration() {
    echo -e "${BLUE}🔗 Testing Backend Integration${NC}"
    echo "----------------------------------------"
    
    # Check if backend is running (optional)
    if curl -s http://localhost:8000/api/v1/workflow/dashboard/ > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend is running - integration tests can run${NC}"
        
        # Run integration tests with real backend
        flutter test test/features/workflow/workflow_integration_test.dart \
            --dart-define=USE_REAL_BACKEND=true
    else
        echo -e "${YELLOW}⚠️  Backend not running - using mocked responses${NC}"
    fi
    echo ""
}

# Main execution
main() {
    echo -e "${GREEN}🎯 EduCV Workflow Frontend Test Suite${NC}"
    echo "======================================"
    echo ""
    
    # Check dependencies
    check_dependencies
    
    # Generate mocks
    generate_mocks
    
    # Validate test quality
    validate_test_quality
    
    # Run all tests
    if run_all_tests; then
        # Generate coverage report
        generate_coverage_report
        
        # Run performance tests
        run_performance_tests
        
        # Test backend integration
        test_backend_integration
        
        echo -e "${GREEN}🎉 All workflow tests completed successfully!${NC}"
        echo ""
        echo -e "${BLUE}📋 Next Steps:${NC}"
        echo "1. Review coverage report at coverage/html/index.html"
        echo "2. Check performance metrics in $REPORTS_DIR/"
        echo "3. Ensure backend integration tests pass"
        echo "4. Run tests in CI/CD pipeline"
        
        exit 0
    else
        echo -e "${RED}❌ Some tests failed. Please review and fix issues.${NC}"
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    "integration")
        generate_mocks
        run_test_suite "$TEST_DIR/workflow_integration_test.dart" "Integration Tests"
        ;;
    "provider")
        generate_mocks
        run_test_suite "$TEST_DIR/workflow_provider_test.dart" "Provider Tests"
        ;;
    "repository")
        generate_mocks
        run_test_suite "$TEST_DIR/workflow_repository_test.dart" "Repository Tests"
        ;;
    "widget")
        run_test_suite "$TEST_DIR/workflow_widget_test.dart" "Widget Tests"
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