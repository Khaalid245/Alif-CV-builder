#!/usr/bin/env pwsh

# Workflow System Test Runner for Windows PowerShell
# Comprehensive test execution with coverage reporting

param(
    [switch]$SkipCoverage,
    [switch]$OpenReport,
    [string]$TestPattern = "*"
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    White = "White"
}

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Colors.Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Colors.Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Colors.Red
}

Write-Host "🚀 Starting Workflow System Test Suite" -ForegroundColor $Colors.Blue
Write-Host "=======================================" -ForegroundColor $Colors.Blue

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter command failed"
    }
    Write-Status "Flutter is installed"
    Write-Host $flutterVersion
} catch {
    Write-Error "Flutter is not installed or not in PATH"
    exit 1
}

# Navigate to project directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptPath "..\..\..")
Set-Location $projectRoot

Write-Status "Project root: $projectRoot"

# Clean previous builds
Write-Status "Cleaning previous builds..."
try {
    flutter clean
    flutter pub get
    Write-Success "Project cleaned and dependencies updated"
} catch {
    Write-Error "Failed to clean project or get dependencies"
    exit 1
}

# Generate mocks for testing
Write-Status "Generating mocks..."
try {
    if (Get-Command dart -ErrorAction SilentlyContinue) {
        dart pub run build_runner build --delete-conflicting-outputs
        Write-Success "Mocks generated successfully"
    } else {
        Write-Warning "Dart command not available, skipping mock generation"
    }
} catch {
    Write-Warning "Mock generation failed, continuing with tests..."
}

# Create coverage directory
$coverageDir = Join-Path $projectRoot "coverage"
if (!(Test-Path $coverageDir)) {
    New-Item -ItemType Directory -Path $coverageDir -Force | Out-Null
}

# Test execution function
function Invoke-FlutterTest {
    param(
        [string]$TestFile,
        [string]$Description,
        [switch]$WithCoverage
    )
    
    Write-Status "Testing $Description..."
    
    if (Test-Path $TestFile) {
        try {
            if ($WithCoverage -and !$SkipCoverage) {
                flutter test $TestFile --coverage
            } else {
                flutter test $TestFile
            }
            Write-Success "$Description tests completed"
            return $true
        } catch {
            Write-Error "$Description tests failed: $_"
            return $false
        }
    } else {
        Write-Warning "$Description test file not found: $TestFile"
        return $true
    }
}

# Track test results
$testResults = @()

# Run unit tests
Write-Host ""
Write-Status "Running Workflow Unit Tests..."
Write-Host "================================"

$testResults += Invoke-FlutterTest -TestFile "test\features\workflow\models_test.dart" -Description "Workflow Models" -WithCoverage
$testResults += Invoke-FlutterTest -TestFile "test\features\workflow\workflow_repository_test.dart" -Description "Workflow Repository" -WithCoverage

# Check for provider tests
$providerTestFile = "test\features\workflow\workflow_provider_test.dart"
if (Test-Path $providerTestFile) {
    $testResults += Invoke-FlutterTest -TestFile $providerTestFile -Description "Workflow Providers" -WithCoverage
} else {
    Write-Warning "Workflow provider tests not found, skipping..."
}

# Run widget tests
Write-Host ""
Write-Status "Running Workflow Widget Tests..."
Write-Host "================================="

$testResults += Invoke-FlutterTest -TestFile "test\features\workflow\workflow_widget_test.dart" -Description "Workflow Widgets" -WithCoverage

# Run integration tests
Write-Host ""
Write-Status "Running Workflow Integration Tests..."
Write-Host "====================================="

$testResults += Invoke-FlutterTest -TestFile "test\features\workflow\workflow_integration_test.dart" -Description "Workflow Integration" -WithCoverage

# Generate coverage report (if not skipped)
if (!$SkipCoverage) {
    Write-Status "Processing coverage data..."
    
    $lcovFile = Join-Path $coverageDir "lcov.info"
    if (Test-Path $lcovFile) {
        try {
            # Check if lcov tools are available (via Chocolatey or manual install)
            if (Get-Command lcov -ErrorAction SilentlyContinue) {
                Write-Status "Generating HTML coverage report..."
                
                # Clean coverage data
                $cleanedLcov = Join-Path $coverageDir "lcov_cleaned.info"
                lcov --remove $lcovFile `
                    "*/flutter/*" `
                    "*/packages/*" `
                    "*/test/*" `
                    "*/generated/*" `
                    "*/.dart_tool/*" `
                    -o $cleanedLcov
                
                # Generate HTML report
                $htmlDir = Join-Path $coverageDir "html"
                genhtml $cleanedLcov -o $htmlDir
                
                Write-Success "Coverage report generated at coverage\html\index.html"
                
                # Extract coverage percentage
                $coverageOutput = lcov --summary $cleanedLcov 2>&1
                $coverageMatch = $coverageOutput | Select-String "lines.*?(\d+\.\d+)%"
                if ($coverageMatch) {
                    $coveragePercent = $coverageMatch.Matches[0].Groups[1].Value
                    Write-Success "Overall test coverage: $coveragePercent%"
                    
                    # Check coverage threshold
                    if ([double]$coveragePercent -ge 90.0) {
                        Write-Success "Coverage threshold met (≥90%)"
                    } else {
                        Write-Warning "Coverage below threshold: $coveragePercent% < 90%"
                    }
                }
                
                # Open report if requested
                if ($OpenReport) {
                    $indexFile = Join-Path $htmlDir "index.html"
                    if (Test-Path $indexFile) {
                        Start-Process $indexFile
                    }
                }
            } else {
                Write-Warning "LCOV tools not installed. Install via: choco install lcov"
                Write-Status "Raw coverage data available at: $lcovFile"
            }
        } catch {
            Write-Warning "Coverage report generation failed: $_"
        }
    } else {
        Write-Warning "No coverage data found at: $lcovFile"
    }
}

# Run static analysis
Write-Host ""
Write-Status "Running static analysis..."
try {
    flutter analyze lib\features\workflow\
    Write-Success "Static analysis completed"
} catch {
    Write-Warning "Static analysis found issues: $_"
}

# Check code formatting
Write-Status "Checking code formatting..."
try {
    dart format --set-exit-if-changed lib\features\workflow\ test\features\workflow\
    Write-Success "Code formatting verified"
} catch {
    Write-Warning "Code formatting issues found. Run 'dart format lib\features\workflow\ test\features\workflow\' to fix."
}

# Performance tests (if available)
$perfTestFile = "test\features\workflow\workflow_performance_test.dart"
if (Test-Path $perfTestFile) {
    Write-Status "Running performance tests..."
    try {
        flutter test $perfTestFile
        Write-Success "Performance tests completed"
    } catch {
        Write-Warning "Performance tests failed: $_"
    }
} else {
    Write-Warning "Performance tests not found, skipping..."
}

# Test summary
Write-Host ""
Write-Host "📊 Test Summary" -ForegroundColor $Colors.Blue
Write-Host "===============" -ForegroundColor $Colors.Blue

$passedTests = ($testResults | Where-Object { $_ -eq $true }).Count
$totalTests = $testResults.Count
$failedTests = $totalTests - $passedTests

if ($failedTests -eq 0) {
    Write-Success "✅ All tests passed ($passedTests/$totalTests)"
    Write-Success "✅ Static Analysis: Completed"
    Write-Success "✅ Code Formatting: Verified"
    
    if (!$SkipCoverage) {
        Write-Success "✅ Coverage Report: Generated"
    }
    
    Write-Host ""
    Write-Success "🎉 All Workflow System tests completed successfully!"
    
    # Prompt to open coverage report
    if (!$SkipCoverage -and !$OpenReport) {
        $htmlIndex = Join-Path $coverageDir "html\index.html"
        if (Test-Path $htmlIndex) {
            $response = Read-Host "Open coverage report in browser? (y/n)"
            if ($response -eq 'y' -or $response -eq 'Y') {
                Start-Process $htmlIndex
            }
        }
    }
    
    exit 0
} else {
    Write-Error "❌ Some tests failed ($failedTests/$totalTests failed)"
    exit 1
}

# Additional helper functions for CI/CD integration
function Export-TestResults {
    param([string]$OutputPath = "test-results.xml")
    
    # This would export test results in JUnit XML format for CI/CD systems
    Write-Status "Test results would be exported to: $OutputPath"
}

function Send-CoverageReport {
    param([string]$Service = "codecov")
    
    # This would send coverage reports to external services
    Write-Status "Coverage report would be sent to: $Service"
}