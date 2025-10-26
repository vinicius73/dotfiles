#!/bin/bash

# Node Modules Clean Script
# Purpose: Clean node_modules and .serverless directories from all Node.js projects in the current directory tree

# set -e  # Disabled to prevent script from exiting on non-critical errors

# Simple color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Global variables
VERBOSE=false
DRY_RUN=false
BASE_DIR="."
INCLUDE_SERVERLESS=true

# Simple logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_verbose() {
    [ "$VERBOSE" = true ] && echo -e "${BLUE}🔍 $1${NC}"
}

# Help function
show_help() {
    cat << EOF
Node Modules Clean Script

USAGE:
    $0 [OPTIONS] [BASE_DIRECTORY]

DESCRIPTION:
    Clean node_modules and .serverless directories from all Node.js projects in the specified directory tree.
    Only processes directories that contain both package.json and .git (Git repositories).

ARGUMENTS:
    BASE_DIRECTORY      Directory to search for Node.js projects (default: current directory)

OPTIONS:
    -v, --verbose       Enable verbose output
    -d, --dry-run       Show what would be done without executing
    --no-serverless     Skip .serverless directories (only clean node_modules)
    -h, --help          Show this help message

EXAMPLES:
    $0                          # Clean all Node.js projects in current directory
    $0 /path/to/projects        # Clean all Node.js projects in /path/to/projects
    $0 --verbose --dry-run      # Show what would be cleaned in current directory
    $0 --dry-run /path/to/projects  # Show what would be cleaned in /path/to/projects
    $0 --no-serverless          # Only clean node_modules, skip .serverless
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --no-serverless)
                INCLUDE_SERVERLESS=false
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                # This is the base directory argument
                BASE_DIR="$1"
                shift
                ;;
        esac
    done
}

# Check if a directory is a Node.js project
is_node_project() {
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

# Get directory size in human readable format
get_dir_size() {
    local dir="$1"
    if [ -d "$dir" ]; then
        local size
        if size=$(du -sh "$dir" 2>/dev/null | cut -f1); then
            echo "$size"
        else
            echo "unknown"
        fi
    else
        echo "0B"
    fi
}

# Clean a single project
clean_project() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")

    log_verbose "Processing project: $project_name in $project_dir"

    if ! is_node_project "$project_dir"; then
        log_verbose "Skipping $project_name: not a Node.js project or not a Git repository"
        return 0
    fi

    local total_size=""
    local dirs_to_clean=()
    local sizes=()

    # Check for node_modules
    if [ -d "$project_dir/node_modules" ]; then
        local size=$(get_dir_size "$project_dir/node_modules")
        dirs_to_clean+=("node_modules")
        sizes+=("$size")
        total_size="$size"
    fi

    # Check for .serverless if enabled
    if [ "$INCLUDE_SERVERLESS" = true ] && [ -d "$project_dir/.serverless" ]; then
        local size=$(get_dir_size "$project_dir/.serverless")
        dirs_to_clean+=(".serverless")
        if [ -n "$total_size" ]; then
            total_size="${total_size}+${size}"
        else
            total_size="$size"
        fi
        sizes+=("$size")
    fi

    if [ ${#dirs_to_clean[@]} -eq 0 ]; then
        log_verbose "No directories to clean in $project_name"
        return 0
    fi

    log_info "Cleaning project $project_name (total size: $total_size)"

    local cleaned_dirs=()
    local failed_dirs=()

    for i in "${!dirs_to_clean[@]}"; do
        local dir_name="${dirs_to_clean[$i]}"
        local dir_path="$project_dir/$dir_name"
        local dir_size="${sizes[$i]}"

        if [ "$DRY_RUN" = true ]; then
            log_success "Would remove: $dir_name ($dir_size) from $project_name"
            cleaned_dirs+=("$dir_name")
        else
            if rm -rf "$dir_path"; then
                log_success "Removed: $dir_name ($dir_size) from $project_name"
                cleaned_dirs+=("$dir_name")
            else
                log_error "Failed to remove: $dir_name from $project_name"
                failed_dirs+=("$dir_name")
            fi
        fi
    done

    # Return status based on results
    if [ ${#failed_dirs[@]} -gt 0 ]; then
        return 1
    fi

    return 0
}

# Main execution function
main() {
    log_info "Starting node modules clean process..."

    # Parse arguments
    parse_args "$@"

    # Validate base directory
    if [ ! -d "$BASE_DIR" ]; then
        log_error "Directory '$BASE_DIR' does not exist or is not accessible"
        exit 1
    fi

    # Convert to absolute path
    BASE_DIR=$(cd "$BASE_DIR" && pwd)
    log_verbose "Searching for Node.js projects in: $BASE_DIR"

    # Find all package.json files, excluding common build directories
    local package_files
    log_verbose "Searching for package.json files in: $BASE_DIR"
    
    if ! package_files=$(find "$BASE_DIR" -name 'package.json' -type f \
        -not -path '*/node_modules/*' \
        -not -path '*/.git/*' \
        -not -path '*/target/*' \
        -not -path '*/vendor/*' 2>/dev/null | sort); then
        log_error "Failed to search for package.json files in $BASE_DIR"
        exit 1
    fi

    if [ -z "$package_files" ]; then
        log_info "No package.json files found in $BASE_DIR"
        log_verbose "Searched paths: $BASE_DIR (excluding node_modules, .git, target, vendor)"
        exit 0
    fi

    local project_count=$(echo "$package_files" | wc -l)
    log_info "Found $project_count Node.js project(s)"

    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN MODE - No actual cleaning will be performed"
    fi

    if [ "$INCLUDE_SERVERLESS" = false ]; then
        log_info "SERVERLESS DISABLED - Only cleaning node_modules directories"
    fi

    # Process projects
    local cleaned=0
    local skipped=0
    local failed=0
    local total_files=$(echo "$package_files" | wc -l)
    log_verbose "Starting to process $total_files package.json files"

    while IFS= read -r package_file; do
        local project_dir=$(dirname "$package_file")
        log_verbose "Processing package.json file: $package_file"
        log_verbose "Project directory: $project_dir"

        if clean_project "$project_dir"; then
            ((cleaned++))
            log_verbose "Successfully processed project: $project_dir (processed: $cleaned)"
        else
            ((failed++))
            log_warning "Failed to process project: $project_dir (failed: $failed)"
        fi
    done <<< "$package_files"
    
    log_verbose "Finished processing all projects. Processed: $cleaned, Failed: $failed"

    # Generate final report
    echo
    log_info "=== CLEANUP REPORT ==="
    log_success "Projects processed: $cleaned"
    if [ $failed -gt 0 ]; then
        log_warning "Projects failed: $failed"
        log_info "Check verbose output for details about failed projects"
    fi

    if [ "$DRY_RUN" = true ]; then
        log_warning "This was a dry run. Use without --dry-run to actually clean directories."
    else
        log_success "Node modules cleanup completed successfully!"
    fi
}

# Execute main function
main "$@"
