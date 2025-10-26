#!/bin/bash

# JavaScript Projects Vulnerability Check Script
# Purpose: Check for vulnerabilities in all JavaScript/Node.js projects in the current directory tree

# set -e  # Disabled to prevent script from exiting on non-critical errors

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"

# Global state
VERBOSE=false
DRY_RUN=false
BASE_DIR="."
SEVERITY_LEVEL="low"
OUTPUT_FORMAT="summary"
AUTO_FIX=false
EXCLUDE_PATTERNS=()
OUTPUT_FILE=""
TIMEOUT_SECONDS=300

# Temporary files
TEMP_RESULTS_FILE=""

# Logging functions
log_message() {
    local level="$1"
    local message="$2"
    local color=""

    case "$level" in
        "info") color="$BLUE" ;;
        "success") color="$GREEN" ;;
        "error") color="$RED" ;;
        "warning") color="$YELLOW" ;;
        "verbose")
            [ "$VERBOSE" = true ] || return 0
            color="$BLUE"
            ;;
    esac

    echo -e "${color}${message}${NC}" >&"$([ "$level" = "error" ] && echo 2 || echo 1)"
}

# Cleanup function
cleanup() {
    [ -f "$TEMP_RESULTS_FILE" ] && rm -f "$TEMP_RESULTS_FILE"
}

# Error handling
die() {
    log_message "error" "❌ $1"
    log_message "error" "❌ Script execution failed. Check verbose output for details."
    cleanup
    exit 1
}

# Safe execution wrapper
safe_execute() {
    local cmd="$1"
    local description="$2"
    
    log_message "verbose" "🔍 Executing: $description"
    log_message "verbose" "🔍 Command: $cmd"
    
    if ! eval "$cmd"; then
        local exit_code=$?
        log_message "error" "❌ Failed to execute: $description (exit code: $exit_code)"
        return $exit_code
    fi
    
    return 0
}

# Help function
show_help() {
    cat << EOF
JavaScript Projects Vulnerability Check Script

USAGE:
    $SCRIPT_NAME [OPTIONS] [BASE_DIRECTORY]

DESCRIPTION:
    Check for vulnerabilities in all JavaScript/Node.js projects in the specified directory tree.
    Supports npm, Yarn (v1 and v2+), pnpm, and Bun package managers.
    Only processes directories that contain both package.json and .git (Git repositories).

ARGUMENTS:
    BASE_DIRECTORY      Directory to search for JavaScript projects (default: current directory)

OPTIONS:
    -v, --verbose       Enable verbose output
    -d, --dry-run       Show what would be done without executing
    -s, --severity LEVEL    Minimum severity level to report (low|moderate|high|critical) (default: moderate)
    -f, --format FORMAT     Output format (summary|json) (default: summary)
    -o, --output FILE   Save report to file (in addition to console output)
    --fix               Attempt to automatically fix vulnerabilities where possible
    --exclude PATTERN   Exclude projects matching pattern (can be used multiple times)
    --timeout SECONDS   Timeout for audit commands (default: 300)
    -h, --help          Show this help message

EXAMPLES:
    $SCRIPT_NAME                          # Check all JavaScript projects in current directory
    $SCRIPT_NAME /path/to/projects        # Check all JavaScript projects in /path/to/projects
    $SCRIPT_NAME --verbose --dry-run      # Show what would be checked in current directory
    $SCRIPT_NAME --severity high          # Only report high and critical vulnerabilities
    $SCRIPT_NAME --format json            # Output results in JSON format
    $SCRIPT_NAME --output report.json     # Save results to file
    $SCRIPT_NAME --fix                    # Attempt to fix vulnerabilities automatically
    $SCRIPT_NAME --exclude "test-*"       # Exclude projects starting with "test-"
    $SCRIPT_NAME --timeout 600            # Set 10-minute timeout for audit commands
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose) VERBOSE=true; shift ;;
            -d|--dry-run) DRY_RUN=true; shift ;;
            -s|--severity)
                SEVERITY_LEVEL="$2"
                [[ "$SEVERITY_LEVEL" =~ ^(low|moderate|high|critical)$ ]] ||
                    die "Invalid severity level: $SEVERITY_LEVEL. Must be one of: low, moderate, high, critical"
                shift 2
                ;;
            -f|--format)
                OUTPUT_FORMAT="$2"
                [[ "$OUTPUT_FORMAT" =~ ^(summary|json)$ ]] ||
                    die "Invalid output format: $OUTPUT_FORMAT. Must be one of: summary, json"
                shift 2
                ;;
            -o|--output) OUTPUT_FILE="$2"; shift 2 ;;
            --fix) AUTO_FIX=true; shift ;;
            --exclude) EXCLUDE_PATTERNS+=("$2"); shift 2 ;;
            --timeout)
                TIMEOUT_SECONDS="$2"
                [[ "$TIMEOUT_SECONDS" =~ ^[0-9]+$ ]] && [ "$TIMEOUT_SECONDS" -gt 0 ] ||
                    die "Invalid timeout value: $TIMEOUT_SECONDS. Must be a positive integer."
                shift 2
                ;;
            -h|--help) show_help; exit 0 ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                BASE_DIR="$1"
                shift
                ;;
        esac
    done
}

# Check system dependencies
check_dependencies() {
    local missing_deps=()

    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    command -v timeout >/dev/null 2>&1 || log_message "warning" "⚠️  timeout command not found, timeout functionality will be limited"

    if [ ${#missing_deps[@]} -gt 0 ]; then
        die "Missing required dependencies: ${missing_deps[*]}. Please install: brew install jq (macOS) or sudo apt-get install jq (Ubuntu)"
    fi
}


# Check if directory is a JavaScript project
is_js_project() {
    local dir="$1"
    local current_dir="$dir"
    
    # Check if package.json exists
    [ ! -f "$dir/package.json" ] && return 1
    
    # Look for .git directory in current dir or parent directories
    while [ "$current_dir" != "/" ] && [ "$current_dir" != "." ]; do
        if [ -d "$current_dir/.git" ]; then
            return 0
        fi
        current_dir=$(dirname "$current_dir")
    done
    
    return 1
}

# Check if project should be excluded
is_excluded() {
    local project_name="$1"
    local project_path="$2"

    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        [[ "$project_name" == $pattern ]] || [[ "$project_path" == *"$pattern"* ]] && return 0
    done
    return 1
}

# Detect package manager
detect_package_manager() {
    local project_dir="$1"

    [ -f "$project_dir/pnpm-lock.yaml" ] && echo "pnpm" && return 0
    [ -f "$project_dir/bun.lockb" ] && echo "bun" && return 0
    [ -f "$project_dir/yarn.lock" ] && ([ -f "$project_dir/.yarnrc.yml" ] || [ -d "$project_dir/.yarn" ]) && echo "yarn2" && return 0
    [ -f "$project_dir/yarn.lock" ] && echo "yarn1" && return 0
    [ -f "$project_dir/package-lock.json" ] && echo "npm" && return 0

    echo "npm"  # default
}

# Check if package manager is available
is_package_manager_available() {
    local manager="$1"
    case "$manager" in
        "npm"|"yarn1"|"yarn2") command -v npm >/dev/null 2>&1 || command -v yarn >/dev/null 2>&1 ;;
        "pnpm") command -v pnpm >/dev/null 2>&1 ;;
        "bun") command -v bun >/dev/null 2>&1 ;;
        *) return 1 ;;
    esac
}

# Get audit command
get_audit_command() {
    local manager="$1"
    local severity="$2"

    case "$manager" in
        "npm")
            local cmd="npm audit --json"
            [ "$severity" != "low" ] && cmd="$cmd --audit-level=$severity"
            [ "$AUTO_FIX" = true ] && cmd="$cmd --fix"
            echo "$cmd"
            ;;
        "yarn1")
            local cmd="yarn audit --json"
            [ "$severity" != "low" ] && cmd="$cmd --level $severity"
            echo "$cmd"
            ;;
        "yarn2")
            local cmd="yarn npm audit --json"
            [ "$severity" != "low" ] && cmd="$cmd --severity=$severity"
            echo "$cmd"
            ;;
        "pnpm")
            local cmd="pnpm audit --json"
            [ "$severity" != "low" ] && cmd="$cmd --audit-level=$severity"
            echo "$cmd"
            ;;
        "bun")
            echo "bun audit --json"
            ;;
    esac
}

# Execute command with timeout
execute_with_timeout() {
    local cmd="$1"
    local timeout_sec="$2"
    local output_file="$3"
    local exit_code=0

    if command -v timeout >/dev/null 2>&1; then
        if ! timeout "$timeout_sec" bash -c "$cmd" > "$output_file" 2>&1; then
            exit_code=$?
            # timeout returns 124 when command times out
            if [ $exit_code -eq 124 ]; then
                echo "Command timed out after ${timeout_sec}s" >> "$output_file"
            fi
        fi
    else
        if ! bash -c "$cmd" > "$output_file" 2>&1; then
            exit_code=$?
        fi
    fi
    
    return $exit_code
}

# Parse audit output
parse_audit_output() {
    local output="$1"
    local manager="$2"

    local critical=0 high=0 moderate=0 low=0 total=0

    # Check if output is empty
    if [ -z "$output" ]; then
        log_message "verbose" "🔍 Empty audit output received"
        echo "0 0 0 0 0"
        return 0
    fi

    # Try JSON parsing first
    if echo "$output" | jq -e '.metadata.vulnerabilities' >/dev/null 2>&1; then
        # npm/pnpm JSON format
        critical=$(echo "$output" | jq -r '.metadata.vulnerabilities.critical // 0')
        high=$(echo "$output" | jq -r '.metadata.vulnerabilities.high // 0')
        moderate=$(echo "$output" | jq -r '.metadata.vulnerabilities.moderate // 0')
        low=$(echo "$output" | jq -r '.metadata.vulnerabilities.low // 0')
        log_message "verbose" "🔍 Parsed JSON format (metadata.vulnerabilities): C=$critical H=$high M=$moderate L=$low"
    elif echo "$output" | jq -e '.data.vulnerabilities' >/dev/null 2>&1; then
        # Yarn v1 JSON format
        critical=$(echo "$output" | jq -r '.data.vulnerabilities.critical // 0')
        high=$(echo "$output" | jq -r '.data.vulnerabilities.high // 0')
        moderate=$(echo "$output" | jq -r '.data.vulnerabilities.moderate // 0')
        low=$(echo "$output" | jq -r '.data.vulnerabilities.low // 0')
        log_message "verbose" "🔍 Parsed JSON format (data.vulnerabilities): C=$critical H=$high M=$moderate L=$low"
    elif echo "$output" | grep -q '"Severity":' && echo "$output" | grep -q '"Issue":'; then
        # Yarn v2+ format - count by severity
        critical=$(echo "$output" | grep -o '"Severity":"critical"' | wc -l || echo "0")
        high=$(echo "$output" | grep -o '"Severity":"high"' | wc -l || echo "0")
        moderate=$(echo "$output" | grep -o '"Severity":"moderate"' | wc -l || echo "0")
        low=$(echo "$output" | grep -o '"Severity":"low"' | wc -l || echo "0")
        log_message "verbose" "🔍 Parsed Yarn v2+ format: C=$critical H=$high M=$moderate L=$low"
    else
        # Fallback: parse text output
        critical=$(echo "$output" | grep -o '[0-9]* critical' | grep -o '[0-9]*' || echo "0")
        high=$(echo "$output" | grep -o '[0-9]* high' | grep -o '[0-9]*' || echo "0")
        moderate=$(echo "$output" | grep -o '[0-9]* moderate' | grep -o '[0-9]*' || echo "0")
        low=$(echo "$output" | grep -o '[0-9]* low' | grep -o '[0-9]*' || echo "0")
        log_message "verbose" "🔍 Parsed text format: C=$critical H=$high M=$moderate L=$low"
    fi

    total=$((critical + high + moderate + low))
    echo "$critical $high $moderate $low $total"
}

# Validate project
validate_project() {
    local project_dir="$1"
    local project_name="$2"

    if ! is_js_project "$project_dir"; then
        log_message "verbose" "🔍 Skipping $project_name: not a JavaScript project or not a Git repository"
        return 1
    fi

    if is_excluded "$project_name" "$project_dir"; then
        log_message "verbose" "🔍 Skipping $project_name: matches exclusion pattern"
        return 1
    fi

    # Check if dependencies are available (node_modules or .yarn/cache for Yarn v2+)
    local has_dependencies=false
    if [ -d "$project_dir/node_modules" ]; then
        has_dependencies=true
    elif [ -d "$project_dir/.yarn/cache" ] && [ -f "$project_dir/.yarnrc.yml" ]; then
        has_dependencies=true
    fi

    if [ "$has_dependencies" = false ]; then
        log_message "verbose" "🔍 No dependencies found in $project_name, skipping audit"
        log_message "verbose" "🔍 Project directory: $project_dir"
        return 1
    fi

    return 0
}

# Run audit for project
run_audit() {
    local project_dir="$1"
    local project_name="$2"
    local manager="$3"

    local audit_cmd=$(get_audit_command "$manager" "$SEVERITY_LEVEL")
    [ -z "$audit_cmd" ] && die "No audit command available for $manager"

    # Run audit
    local temp_output_file=$(mktemp)

    local cmd="cd '$project_dir' && $audit_cmd"
    log_message "verbose" "🔍 Running audit command: $audit_cmd (timeout: ${TIMEOUT_SECONDS}s)"

    local exit_code=0
    if ! execute_with_timeout "$cmd" "$TIMEOUT_SECONDS" "$temp_output_file"; then
        exit_code=$?
    fi

    local audit_output=$(cat "$temp_output_file")
    
    # Clean up temp file
    rm -f "$temp_output_file"

    # Exit code 1 is normal when vulnerabilities are found
    if [ $exit_code -eq 124 ]; then
        log_message "error" "❌ Audit command timed out after ${TIMEOUT_SECONDS}s for $project_name"
        log_message "verbose" "🔍 Command output: $audit_output"
        return 1
    elif [ $exit_code -ne 0 ] && [ $exit_code -ne 1 ]; then
        log_message "error" "❌ Failed to audit $project_name (exit code: $exit_code)"
        log_message "verbose" "🔍 Command output: $audit_output"
        return 1
    fi

    # Parse and store results
    local results=$(parse_audit_output "$audit_output" "$manager")
    if [ -z "$results" ]; then
        log_message "error" "❌ Failed to parse audit output for $project_name"
        log_message "verbose" "🔍 Raw audit output: $audit_output"
        return 1
    fi
    
    local critical=$(echo "$results" | cut -d' ' -f1)
    local high=$(echo "$results" | cut -d' ' -f2)
    local moderate=$(echo "$results" | cut -d' ' -f3)
    local low=$(echo "$results" | cut -d' ' -f4)
    local total=$(echo "$results" | cut -d' ' -f5)
    
    # Validate parsed results - clean any non-numeric characters
    critical=$(echo "$critical" | tr -d '[:alpha:][:space:][:punct:]' | { grep -o '^[0-9]*$' || echo "0"; })
    high=$(echo "$high" | tr -d '[:alpha:][:space:][:punct:]' | { grep -o '^[0-9]*$' || echo "0"; })
    moderate=$(echo "$moderate" | tr -d '[:alpha:][:space:][:punct:]' | { grep -o '^[0-9]*$' || echo "0"; })
    low=$(echo "$low" | tr -d '[:alpha:][:space:][:punct:]' | { grep -o '^[0-9]*$' || echo "0"; })
    total=$((critical + high + moderate + low))
    
    # Validate final results
    if ! [[ "$critical" =~ ^[0-9]+$ ]] || ! [[ "$high" =~ ^[0-9]+$ ]] || ! [[ "$moderate" =~ ^[0-9]+$ ]] || ! [[ "$low" =~ ^[0-9]+$ ]] || ! [[ "$total" =~ ^[0-9]+$ ]]; then
        log_message "error" "❌ Invalid vulnerability counts parsed for $project_name: critical=$critical, high=$high, moderate=$moderate, low=$low, total=$total"
        log_message "verbose" "🔍 Raw audit output: $audit_output"
        return 1
    fi

    if [ "$total" -gt 0 ]; then
        log_message "warning" "⚠️  Found $total vulnerabilities in $project_name: $critical critical, $high high, $moderate moderate, $low low"
        echo "$project_name|$critical|$high|$moderate|$low|$total" >> "$TEMP_RESULTS_FILE"
    else
        log_message "success" "✅ No vulnerabilities found in $project_name"
    fi

    # JSON output is handled in main function
    return 0
}

# Check single project
check_project() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")

    log_message "verbose" "🔍 Processing project: $project_name in $project_dir"

    # Validate project
    validate_project "$project_dir" "$project_name" || return 0

    # Detect package manager
    local manager=$(detect_package_manager "$project_dir")
    log_message "verbose" "🔍 Detected package manager: $manager for $project_name"

    # Check if package manager is available
    if ! is_package_manager_available "$manager"; then
        log_message "warning" "⚠️  Package manager '$manager' not available, skipping $project_name"
        log_message "verbose" "🔍 Available package managers: $(command -v npm 2>/dev/null && echo "npm" || true) $(command -v yarn 2>/dev/null && echo "yarn" || true) $(command -v pnpm 2>/dev/null && echo "pnpm" || true) $(command -v bun 2>/dev/null && echo "bun" || true)"
        return 0
    fi

    log_message "info" "ℹ️  Checking vulnerabilities in $project_name (using $manager)"

    if [ "$DRY_RUN" = true ]; then
        log_message "success" "✅ Would check vulnerabilities in: $project_name"
        return 0
    fi

    # Run audit
    run_audit "$project_dir" "$project_name" "$manager"
}

# Generate summary report
generate_summary() {
    local results_file="$1"
    local silent_mode="${2:-false}"

    [ ! -f "$results_file" ] && [ "$silent_mode" = false ] && log_message "info" "ℹ️  No vulnerability results to report" && return 0

    local total_projects=0 projects_with_vulns=0 total_critical=0 total_high=0 total_moderate=0 total_low=0 total_vulns=0

    # Count totals
    while IFS='|' read -r project critical high moderate low total; do
        ((total_projects++))
        if [ "$total" -gt 0 ]; then
            ((projects_with_vulns++))
            total_critical=$((total_critical + critical))
            total_high=$((total_high + high))
            total_moderate=$((total_moderate + moderate))
            total_low=$((total_low + low))
            total_vulns=$((total_vulns + total))
        fi
    done < "$results_file"

    # Generate report
    local report_lines=()
    report_lines+=("=== VULNERABILITY REPORT ===")
    report_lines+=("Projects scanned: $total_projects")
    report_lines+=("Projects with vulnerabilities: $projects_with_vulns")

    if [ "$total_vulns" -gt 0 ]; then
        report_lines+=("Total vulnerabilities found: $total_vulns")
        [ "$total_critical" -gt 0 ] && report_lines+=("  - Critical: $total_critical")
        [ "$total_high" -gt 0 ] && report_lines+=("  - High: $total_high")
        [ "$total_moderate" -gt 0 ] && report_lines+=("  - Moderate: $total_moderate")
        [ "$total_low" -gt 0 ] && report_lines+=("  - Low: $total_low")

        report_lines+=("")
        report_lines+=("Projects with vulnerabilities:")
        while IFS='|' read -r project critical high moderate low total; do
            if [ "$total" -gt 0 ]; then
                local severity_info=""
                [ "$critical" -gt 0 ] && severity_info="${severity_info}${critical}C "
                [ "$high" -gt 0 ] && severity_info="${severity_info}${high}H "
                [ "$moderate" -gt 0 ] && severity_info="${severity_info}${moderate}M "
                [ "$low" -gt 0 ] && severity_info="${severity_info}${low}L"
                report_lines+=("  - $project: $total total ($severity_info)")
            fi
        done < "$results_file"
    else
        report_lines+=("No vulnerabilities found in any project!")
    fi

    # Output report
    for line in "${report_lines[@]}"; do
        if [ "$silent_mode" = false ]; then
            case "$line" in
                *"Critical:"*) log_message "error" "$line" ;;
                *"High:"*) log_message "error" "$line" ;;
                *"Moderate:"*) log_message "warning" "$line" ;;
                *"Low:"*) log_message "info" "$line" ;;
                *"No vulnerabilities found"*) log_message "success" "$line" ;;
                *"Total vulnerabilities found"*) log_message "warning" "$line" ;;
                *"Projects with vulnerabilities:"*) log_message "info" "$line" ;;
                *"Projects scanned:"*|*"Projects with vulnerabilities:"*) log_message "info" "$line" ;;
                *"=== VULNERABILITY REPORT ==="*) log_message "info" "$line" ;;
                *) echo "$line" ;;
            esac
        else
            echo "$line"
        fi
    done
}

# Generate JSON report
generate_json_report() {
    local results_file="$1"

    if [ ! -f "$results_file" ]; then
        echo '{"projects": [], "summary": {"total_projects": 0, "projects_with_vulnerabilities": 0, "total_vulnerabilities": 0, "critical": 0, "high": 0, "moderate": 0, "low": 0}}'
        return 0
    fi

    local total_projects=0
    local projects_with_vulns=0
    local total_critical=0
    local total_high=0
    local total_moderate=0
    local total_low=0
    local total_vulns=0
    local projects_json=""

    # Count totals and build projects array
    while IFS='|' read -r project critical high moderate low total; do
        ((total_projects++))
        if [ "$total" -gt 0 ]; then
            ((projects_with_vulns++))
            total_critical=$((total_critical + critical))
            total_high=$((total_high + high))
            total_moderate=$((total_moderate + moderate))
            total_low=$((total_low + low))
            total_vulns=$((total_vulns + total))

            if [ -n "$projects_json" ]; then
                projects_json="$projects_json,"
            fi
            projects_json="$projects_json{\"name\":\"$project\",\"critical\":$critical,\"high\":$high,\"moderate\":$moderate,\"low\":$low,\"total\":$total}"
        fi
    done < "$results_file"

    echo "{\"projects\":[$projects_json],\"summary\":{\"total_projects\":$total_projects,\"projects_with_vulnerabilities\":$projects_with_vulns,\"total_vulnerabilities\":$total_vulns,\"critical\":$total_critical,\"high\":$total_high,\"moderate\":$total_moderate,\"low\":$total_low}}"
}

# Main execution function
main() {
    log_message "info" "ℹ️  Starting JavaScript vulnerability check process..."

    # Parse arguments and validate
    parse_args "$@"
    check_dependencies

    # Validate base directory
    [ ! -d "$BASE_DIR" ] && die "Directory '$BASE_DIR' does not exist or is not accessible"
    BASE_DIR=$(cd "$BASE_DIR" && pwd)
    log_message "verbose" "🔍 Searching for JavaScript projects in: $BASE_DIR"

    # Create temporary results file
    TEMP_RESULTS_FILE=$(mktemp)

    # Find projects
    local package_files
    log_message "verbose" "🔍 Searching for package.json files in: $BASE_DIR"
    
    if ! package_files=$(find "$BASE_DIR" -name 'package.json' -type f \
        -not -path '*/node_modules/*' \
        -not -path '*/.git/*' \
        -not -path '*/target/*' \
        -not -path '*/vendor/*' 2>/dev/null | sort); then
        die "Failed to search for package.json files in $BASE_DIR"
    fi

    if [ -z "$package_files" ]; then
        log_message "info" "ℹ️  No package.json files found in $BASE_DIR"
        log_message "verbose" "🔍 Searched paths: $BASE_DIR (excluding node_modules, .git, target, vendor)"
        exit 0
    fi

    local project_count=$(echo "$package_files" | wc -l)
    log_message "info" "ℹ️  Found $project_count JavaScript project(s)"

    [ "$DRY_RUN" = true ] && log_message "info" "ℹ️  DRY RUN MODE - No actual vulnerability checks will be performed"
    [ "$AUTO_FIX" = true ] && log_message "info" "ℹ️  AUTO FIX MODE - Will attempt to fix vulnerabilities where possible"
    log_message "info" "ℹ️  Severity level: $SEVERITY_LEVEL"
    log_message "info" "ℹ️  Output format: $OUTPUT_FORMAT"

    # Process projects
    local processed=0 failed=0
    local total_files=$(echo "$package_files" | wc -l)
    log_message "verbose" "🔍 Starting to process $total_files package files"

    while IFS= read -r package_file; do
        local project_dir=$(dirname "$package_file")
        log_message "verbose" "🔍 Processing package file: $package_file"
        log_message "verbose" "🔍 Project directory: $project_dir"
        
    if check_project "$project_dir"; then
        ((processed++))
    else
        ((failed++))
        log_message "warning" "⚠️  Failed to process project: $project_dir"
    fi
    done <<< "$package_files"
    
    log_message "verbose" "🔍 Finished processing all projects. Processed: $processed, Failed: $failed"

    # Generate reports
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        local json_output=$(generate_json_report "$TEMP_RESULTS_FILE")
        if [ -n "$OUTPUT_FILE" ]; then
            echo "$json_output" > "$OUTPUT_FILE"
            log_message "success" "✅ JSON report saved to: $OUTPUT_FILE"
        else
            echo "$json_output"
        fi
    else
        if [ -n "$OUTPUT_FILE" ]; then
            {
                echo "JavaScript Vulnerability Check Report"
                echo "Generated on: $(date)"
                echo "Base directory: $BASE_DIR"
                echo "Severity level: $SEVERITY_LEVEL"
                echo "=========================================="
                echo
                generate_summary "$TEMP_RESULTS_FILE" true
                echo
                echo "=== SCAN SUMMARY ==="
                echo "Projects processed: $processed"
                [ $failed -gt 0 ] && echo "Projects failed: $failed"
            } > "$OUTPUT_FILE"
            log_message "success" "✅ Report saved to: $OUTPUT_FILE"
        fi

        generate_summary "$TEMP_RESULTS_FILE"
    fi

    # Final status
    echo
    log_message "info" "ℹ️  === SCAN SUMMARY ==="
    log_message "success" "✅ Projects processed: $processed"
    if [ $failed -gt 0 ]; then
        log_message "warning" "⚠️  Projects failed: $failed"
        log_message "info" "ℹ️  Check verbose output for details about failed projects"
    fi

    if [ "$DRY_RUN" = true ]; then
        log_message "warning" "⚠️  This was a dry run. Use without --dry-run to actually check vulnerabilities."
    else
        log_message "success" "✅ JavaScript vulnerability check completed successfully!"
    fi

}

# Set up cleanup trap
trap cleanup EXIT

# Execute main function
main "$@"
