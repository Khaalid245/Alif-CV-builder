@echo off
setlocal enabledelayedexpansion

REM CV Intelligence Frontend Test Runner for Windows
REM Comprehensive test suite for the EduCV CV Intelligence feature

echo 🧠 CV Intelligence Frontend Test Suite
echo ======================================

REM Test configuration
set TEST_DIR=test\features\cv_intelligence
set COVERAGE_DIR=coverage

REM Create coverage directory if it doesn't exist
if not exist %COVERAGE_DIR% mkdir %COVERAGE_DIR%

echo 📋 Test Configuration
echo Test Directory: %TEST_DIR%
echo Coverage Directory: %COVERAGE_DIR%
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

REM Function to run all CV Intelligence tests
:run_all_tests
echo 🎯 Running All CV Intelligence Tests
echo ========================================

set failed_tests=

REM Models Tests
call :run_test_suite "%TEST_DIR%\models_test.dart" "Models Tests"
if %errorlevel% neq 0 set failed_tests=!failed_tests! "Models Tests"
echo.

REM Repository Tests
call :run_test_suite "%TEST_DIR%\repository_test.dart" "Repository Tests"
if %errorlevel% neq 0 set failed_tests=!failed_tests! "Repository Tests"
echo.

REM Provider Tests
call :run_test_suite "%TEST_DIR%\provider_test.dart" "Provider Tests"
if %errorlevel% neq 0 set failed_tests=!failed_tests! "Provider Tests"
echo.

REM Widget Tests
call :run_test_suite "%TEST_DIR%\widget_test.dart" "Widget Tests"
if %errorlevel% neq 0 set failed_tests=!failed_tests! "Widget Tests"
echo.

REM Integration Tests
call :run_test_suite "%TEST_DIR%\integration_test.dart" "Integration Tests"
if %errorlevel% neq 0 set failed_tests=!failed_tests! "Integration Tests"
echo.

REM Summary
echo 📊 Test Summary
echo ========================================

if "!failed_tests!"=="" (
    echo 🎉 All CV Intelligence tests passed!
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

REM Function to check test coverage
:check_coverage
echo 📊 Checking Test Coverage
echo ----------------------------------------

if exist "coverage\lcov.info" (
    echo Coverage data available in coverage\lcov.info
    echo Use VS Code Flutter extension or online tools for coverage analysis
) else (
    echo ⚠️  No coverage data found
)
echo.
exit /b 0

REM Function to run performance tests
:run_performance_tests
echo ⚡ Running Performance Tests
echo ----------------------------------------

flutter test --reporter=json %TEST_DIR% > %COVERAGE_DIR%\performance_report.json 2>nul

echo ✅ Performance tests completed
echo Performance data saved to %COVERAGE_DIR%\performance_report.json
echo.
exit /b 0

REM Main execution
:main
echo 🎯 EduCV CV Intelligence Test Suite
echo ======================================
echo.

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
    
    REM Check coverage
    call :check_coverage
    
    REM Run performance tests
    call :run_performance_tests
    
    echo 🎉 All CV Intelligence tests completed successfully!
    echo.
    echo 📋 Next Steps:
    echo 1. Review coverage report at coverage\html\index.html
    echo 2. Check performance metrics in %COVERAGE_DIR%\
    echo 3. Ensure all tests pass in CI/CD pipeline
    echo 4. Update documentation if needed
    
    exit /b 0
) else (
    echo ❌ Some tests failed. Please review and fix issues.
    exit /b 1
)

REM Handle script arguments
if "%1"=="models" (
    call :generate_mocks
    call :run_test_suite "%TEST_DIR%\models_test.dart" "Models Tests"
    exit /b %errorlevel%
)

if "%1"=="repository" (
    call :generate_mocks
    call :run_test_suite "%TEST_DIR%\repository_test.dart" "Repository Tests"
    exit /b %errorlevel%
)

if "%1"=="provider" (
    call :generate_mocks
    call :run_test_suite "%TEST_DIR%\provider_test.dart" "Provider Tests"
    exit /b %errorlevel%
)

if "%1"=="widget" (
    call :run_test_suite "%TEST_DIR%\widget_test.dart" "Widget Tests"
    exit /b %errorlevel%
)

if "%1"=="integration" (
    call :generate_mocks
    call :run_test_suite "%TEST_DIR%\integration_test.dart" "Integration Tests"
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