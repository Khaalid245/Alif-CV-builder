@echo off
setlocal enabledelayedexpansion

REM Workflow Frontend Integration Test Runner for Windows
REM Comprehensive test suite for the EduCV Workflow Control System

echo 🚀 Starting Workflow Frontend Integration Tests
echo ================================================

REM Test configuration
set TEST_DIR=test\features\workflow
set COVERAGE_DIR=coverage
set REPORTS_DIR=test_reports

REM Create directories if they don't exist
if not exist %COVERAGE_DIR% mkdir %COVERAGE_DIR%
if not exist %REPORTS_DIR% mkdir %REPORTS_DIR%

echo 📋 Test Configuration
echo Test Directory: %TEST_DIR%
echo Coverage Directory: %COVERAGE_DIR%
echo Reports Directory: %REPORTS_DIR%
echo.

REM Function to run a specific test suite
:run_test_suite
set test_file=%1
set test_name=%2

echo 🧪 Running %test_name%
echo ----------------------------------------

flutter test %test_file% --coverage --reporter=expanded
if %errorlevel% equ 0 (
    echo ✅ %test_name% passed
    exit /b 0
) else (
    echo ❌ %test_name% failed
    exit /b 1
)

REM Function to generate mock files
:generate_mocks
echo 🔧 Generating mock files
echo ----------------------------------------

flutter packages pub run build_runner build --delete-conflicting-outputs

if %errorlevel% equ 0 (
    echo ✅ Mock files generated successfully
) else (
    echo ❌ Failed to generate mock files
    exit /b 1
)
echo.
exit /b 0

REM Function to check test dependencies
:check_dependencies
echo 📦 Checking test dependencies
echo ----------------------------------------

REM Check if required packages are in pubspec.yaml
findstr /c:"flutter_test:" pubspec.yaml >nul
if %errorlevel% neq 0 set missing_deps=!missing_deps! flutter_test

findstr /c:"mockito:" pubspec.yaml >nul
if %errorlevel% neq 0 set missing_deps=!missing_deps! mockito

findstr /c:"build_runner:" pubspec.yaml >nul
if %errorlevel% neq 0 set missing_deps=!missing_deps! build_runner

findstr /c:"hooks_riverpod:" pubspec.yaml >nul
if %errorlevel% neq 0 set missing_deps=!missing_deps! hooks_riverpod

if "!missing_deps!"=="" (
    echo ✅ All required test dependencies are installed
) else (
    echo ❌ Missing test dependencies: !missing_deps!
    echo Please add the following to your pubspec.yaml dev_dependencies:
    echo   flutter_test: sdk: flutter
    echo   mockito: ^latest_version
    echo   build_runner: ^latest_version
    echo   hooks_riverpod: ^latest_version
    exit /b 1
)
echo.
exit /b 0

REM Function to run all workflow tests
:run_all_tests
echo 🎯 Running All Workflow Tests
echo ========================================

set failed_tests=

REM Integration Tests
call :run_test_suite "%TEST_DIR%\workflow_integration_test.dart" "Integration Tests"
if %errorlevel% neq 0 set failed_tests=!failed_tests! "Integration Tests"
echo.

REM Provider Tests
call :run_test_suite "%TEST_DIR%\workflow_provider_test.dart" "Provider Tests"
if %errorlevel% neq 0 set failed_tests=!failed_tests! "Provider Tests"
echo.

REM Repository Tests
call :run_test_suite "%TEST_DIR%\workflow_repository_test.dart" "Repository Tests"
if %errorlevel% neq 0 set failed_tests=!failed_tests! "Repository Tests"
echo.

REM Widget Tests
call :run_test_suite "%TEST_DIR%\workflow_widget_test.dart" "Widget Tests"
if %errorlevel% neq 0 set failed_tests=!failed_tests! "Widget Tests"
echo.

REM Summary
echo 📊 Test Summary
echo ========================================

if "!failed_tests!"=="" (
    echo 🎉 All workflow tests passed!
    exit /b 0
) else (
    echo ❌ Failed test suites: !failed_tests!
    exit /b 1
)

REM Function to generate coverage report
:generate_coverage_report
echo 📈 Generating Coverage Report
echo ----------------------------------------

REM Check if lcov is available (usually not on Windows)
where lcov >nul 2>nul
if %errorlevel% equ 0 (
    lcov --remove coverage\lcov.info */test/* */generated/* */mocks/* */.dart_tool/* -o coverage\lcov_cleaned.info
    genhtml coverage\lcov_cleaned.info -o coverage\html
    echo ✅ Coverage report generated at coverage\html\index.html
) else (
    echo ⚠️  lcov not available on Windows. Coverage data available in coverage\lcov.info
    echo Consider using VS Code Flutter extension for coverage visualization
)
echo.
exit /b 0

REM Function to run performance tests
:run_performance_tests
echo ⚡ Running Performance Tests
echo ----------------------------------------

flutter test --reporter=json %TEST_DIR% > %REPORTS_DIR%\performance_report.json

echo ✅ Performance tests completed
echo Performance data saved to %REPORTS_DIR%\performance_report.json
echo.
exit /b 0

REM Function to validate test quality
:validate_test_quality
echo 🔍 Validating Test Quality
echo ----------------------------------------

set quality_issues=

for %%f in (%TEST_DIR%\*.dart) do (
    findstr /c:"group\|testWidgets\|test" "%%f" >nul
    if !errorlevel! neq 0 set quality_issues=!quality_issues! "%%f: No test cases found"
    
    findstr /c:"expect\|verify" "%%f" >nul
    if !errorlevel! neq 0 set quality_issues=!quality_issues! "%%f: No assertions found"
    
    findstr /c:"setUp\|tearDown" "%%f" >nul
    if !errorlevel! equ 0 echo ✅ %%~nxf: Has proper setup/teardown
)

if "!quality_issues!"=="" (
    echo ✅ All tests meet quality standards
) else (
    echo ⚠️  Quality issues found:
    for %%i in (!quality_issues!) do echo   - %%i
)
echo.
exit /b 0

REM Function to test backend integration
:test_backend_integration
echo 🔗 Testing Backend Integration
echo ----------------------------------------

REM Check if backend is running (using curl if available)
where curl >nul 2>nul
if %errorlevel% equ 0 (
    curl -s http://localhost:8000/api/v1/workflow/dashboard/ >nul 2>nul
    if !errorlevel! equ 0 (
        echo ✅ Backend is running - integration tests can run
        flutter test %TEST_DIR%\workflow_integration_test.dart --dart-define=USE_REAL_BACKEND=true
    ) else (
        echo ⚠️  Backend not running - using mocked responses
    )
) else (
    echo ⚠️  curl not available - cannot check backend status
    echo Using mocked responses for integration tests
)
echo.
exit /b 0

REM Main execution
:main
echo 🎯 EduCV Workflow Frontend Test Suite
echo ======================================
echo.

REM Check dependencies
call :check_dependencies
if %errorlevel% neq 0 exit /b 1

REM Generate mocks
call :generate_mocks
if %errorlevel% neq 0 exit /b 1

REM Validate test quality
call :validate_test_quality

REM Run all tests
call :run_all_tests
if %errorlevel% equ 0 (
    REM Generate coverage report
    call :generate_coverage_report
    
    REM Run performance tests
    call :run_performance_tests
    
    REM Test backend integration
    call :test_backend_integration
    
    echo 🎉 All workflow tests completed successfully!
    echo.
    echo 📋 Next Steps:
    echo 1. Review coverage report at coverage\html\index.html
    echo 2. Check performance metrics in %REPORTS_DIR%\
    echo 3. Ensure backend integration tests pass
    echo 4. Run tests in CI/CD pipeline
    
    exit /b 0
) else (
    echo ❌ Some tests failed. Please review and fix issues.
    exit /b 1
)

REM Handle script arguments
if "%1"=="integration" (
    call :generate_mocks
    call :run_test_suite "%TEST_DIR%\workflow_integration_test.dart" "Integration Tests"
    exit /b %errorlevel%
)

if "%1"=="provider" (
    call :generate_mocks
    call :run_test_suite "%TEST_DIR%\workflow_provider_test.dart" "Provider Tests"
    exit /b %errorlevel%
)

if "%1"=="repository" (
    call :generate_mocks
    call :run_test_suite "%TEST_DIR%\workflow_repository_test.dart" "Repository Tests"
    exit /b %errorlevel%
)

if "%1"=="widget" (
    call :run_test_suite "%TEST_DIR%\workflow_widget_test.dart" "Widget Tests"
    exit /b %errorlevel%
)

if "%1"=="coverage" (
    call :generate_coverage_report
    exit /b %errorlevel%
)

if "%1"=="quality" (
    call :validate_test_quality
    exit /b %errorlevel%
)

REM Default: run main
call :main
exit /b %errorlevel%