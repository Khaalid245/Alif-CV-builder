#!/bin/bash

# Workflow System Test Runner for Unix/Linux/macOS
# Comprehensive test execution with coverage reporting

set -e

echo "🚀 Starting Workflow System Test Suite"
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter version:"
flutter --version

# Navigate to project directory
cd "$(dirname "$0")/../.."

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
flutter pub get

# Generate mocks for testing
print_status "Generating mocks..."
if command -v dart &> /dev/null; then
    dart pub run build_runner build --delete-conflicting-outputs
else
    print_warning "build_runner not available, skipping mock generation"
fi

# Create coverage directory
mkdir -p coverage

# Run unit tests
print_status "Running Workflow Unit Tests..."
echo "================================"

print_status "Testing workflow models..."
flutter test test/features/workflow/models_test.dart --coverage

print_status "Testing workflow repository..."
flutter test test/features/workflow/workflow_repository_test.dart --coverage

print_status "Testing workflow providers..."
if [ -f "test/features/workflow/workflow_provider_test.dart" ]; then
    flutter test test/features/workflow/workflow_provider_test.dart --coverage
else
    print_warning "Workflow provider tests not found, skipping..."
fi

# Run widget tests
print_status "Running Workflow Widget Tests..."
echo "================================="

flutter test test/features/workflow/workflow_widget_test.dart --coverage

# Run integration tests
print_status "Running Workflow Integration Tests..."
echo "====================================="

flutter test test/features/workflow/workflow_integration_test.dart --coverage

# Generate coverage report
print_status "Generating coverage report..."
if command -v lcov &> /dev/null; then
    # Remove Flutter framework files from coverage
    lcov --remove coverage/lcov.info \
        '*/flutter/*' \
        '*/packages/*' \
        '*/test/*' \
        '*/generated/*' \
        '*/.dart_tool/*' \
        -o coverage/lcov_cleaned.info
    
    # Generate HTML coverage report
    genhtml coverage/lcov_cleaned.info -o coverage/html
    
    print_success "Coverage report generated at coverage/html/index.html"
    
    # Extract coverage percentage
    COVERAGE=$(lcov --summary coverage/lcov_cleaned.info 2>&1 | grep "lines" | grep -o '[0-9.]*%' | head -1)
    print_success "Overall test coverage: $COVERAGE"
    
    # Check if coverage meets minimum threshold (90%)
    COVERAGE_NUM=$(echo $COVERAGE | sed 's/%//')
    if (( $(echo "$COVERAGE_NUM >= 90" | bc -l) )); then
        print_success "Coverage threshold met (≥90%)"
    else
        print_warning "Coverage below threshold: $COVERAGE < 90%"
    fi
else
    print_warning "lcov not installed, skipping HTML coverage report"
fi

# Run static analysis
print_status "Running static analysis..."
flutter analyze lib/features/workflow/

# Check for formatting issues
print_status "Checking code formatting..."
dart format --set-exit-if-changed lib/features/workflow/ test/features/workflow/

# Performance tests (if available)
if [ -f "test/features/workflow/workflow_performance_test.dart" ]; then
    print_status "Running performance tests..."
    flutter test test/features/workflow/workflow_performance_test.dart
else
    print_warning "Performance tests not found, skipping..."
fi

# Test summary
echo ""
echo "📊 Test Summary"
echo "==============="
print_success "✅ Unit Tests: Completed"
print_success "✅ Widget Tests: Completed"
print_success "✅ Integration Tests: Completed"
print_success "✅ Static Analysis: Completed"
print_success "✅ Code Formatting: Verified"

if [ -n "$COVERAGE" ]; then
    print_success "✅ Coverage Report: $COVERAGE"
fi

echo ""
print_success "🎉 All Workflow System tests completed successfully!"

# Optional: Open coverage report in browser (macOS/Linux)
if command -v open &> /dev/null && [ -f "coverage/html/index.html" ]; then
    read -p "Open coverage report in browser? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open coverage/html/index.html
    fi
elif command -v xdg-open &> /dev/null && [ -f "coverage/html/index.html" ]; then
    read -p "Open coverage report in browser? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        xdg-open coverage/html/index.html
    fi
fi

exit 0