#!/bin/bash

# Go Bins Clean Script
# Purpose: Clean bin directories from all Go projects in the current directory tree

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
INTERACTIVE=false
FORCE=false
AUTO_YES=false

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
Go Bins Clean Script

USAGE:
    $0 [OPTIONS] [BASE_DIRECTORY]

DESCRIPTION:
    Clean bin directories from all Go projects in the specified directory tree.
    Only processes directories that contain both go.mod and .git (Git repositories).

ARGUMENTS:
    BASE_DIRECTORY      Directory to search for Go projects (default: current directory)

OPTIONS:
    -v, --verbose       Enable verbose output
    -d, --dry-run       Show what would be done without executing
    -i, --interactive   Ask for confirmation before removing each bin directory
    -f, --force         Remove all bin directories without asking (non-interactive)
    -y, --yes           Automatically answer 'yes' to all prompts (non-interactive)
    -h, --help          Show this help message

EXAMPLES:
    $0                          # Clean all Go projects in current directory (interactive)
    $0 /path/to/projects        # Clean all Go projects in /path/to/projects
    $0 --verbose --dry-run      # Show what would be cleaned in current directory
    $0 --dry-run /path/to/projects  # Show what would be cleaned in /path/to/projects
    $0 --force                  # Remove all bin directories without asking
    $0 --yes                    # Automatically answer 'yes' to all prompts
    $0 --interactive            # Ask for confirmation for each bin directory (default)
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
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -y|--yes)
                AUTO_YES=true
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

    # Set default interactive mode if no mode is specified
    if [ "$FORCE" = false ] && [ "$INTERACTIVE" = false ] && [ "$AUTO_YES" = false ]; then
        INTERACTIVE=true
    fi
}

# Check if a directory is a Go project
is_go_project() {
    local dir="$1"
    local current_dir="$dir"
    
    # Check if go.mod exists
    [ ! -f "$dir/go.mod" ] && return 1
    
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

# Ask for user confirmation
ask_confirmation() {
    local bin_dir="$1"
    local project_name="$2"
    local size="$3"

    if [ "$DRY_RUN" = true ]; then
        return 0
    fi

    if [ "$FORCE" = true ]; then
        return 0
    fi

    if [ "$AUTO_YES" = true ]; then
        log_info "Auto-confirming removal of bin directory"
        return 0
    fi

    if [ "$INTERACTIVE" = true ]; then
        echo
        log_warning "Found bin directory in project: $project_name"
        log_info "Location: $bin_dir"
        log_info "Size: $size"
        echo -n "Do you want to remove this bin directory? (y/N): "
        
        # Try to read user input
        # First check if we're in a real terminal
        if [ -t 0 ] && [ -t 1 ]; then
            # We're in a real terminal, try to read normally
            if ! read -r response; then
                log_info "Failed to read input, assuming 'no'"
                return 1
            fi
        else
            # Not in a real terminal, assume 'no' for safety
            log_info "Not in an interactive terminal, assuming 'no'"
            return 1
        fi
        
        case "$response" in
            [yY]|[yY][eE][sS])
                return 0
                ;;
            *)
                return 1
                ;;
        esac
    fi

    return 0
}

# Clean a single project
clean_project() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")

    log_verbose "Processing project: $project_name in $project_dir"

    if ! is_go_project "$project_dir"; then
        log_verbose "Skipping $project_name: not a Go project or not a Git repository"
        return 0
    fi

    # Find all bin directories in the project
    local bin_dirs
    if ! bin_dirs=$(find "$project_dir" -type d -name "bin" 2>/dev/null); then
        log_verbose "Error searching for bin directories in $project_name"
        return 1
    fi

    if [ -z "$bin_dirs" ]; then
        log_verbose "No bin directories found in $project_name"
        return 0
    fi

    local cleaned_dirs=()
    local skipped_dirs=()
    local failed_dirs=()

    while IFS= read -r bin_dir; do
        if [ -z "$bin_dir" ]; then
            continue
        fi

        local size=$(get_dir_size "$bin_dir")
        local relative_path="${bin_dir#$project_dir/}"

        log_verbose "Found bin directory: $relative_path ($size) in $project_name"

        if ask_confirmation "$bin_dir" "$project_name" "$size"; then
            if [ "$DRY_RUN" = true ]; then
                log_success "Would remove: $relative_path ($size) from $project_name"
                cleaned_dirs+=("$relative_path")
            else
                if rm -rf "$bin_dir"; then
                    log_success "Removed: $relative_path ($size) from $project_name"
                    cleaned_dirs+=("$relative_path")
                else
                    log_error "Failed to remove: $relative_path from $project_name"
                    failed_dirs+=("$relative_path")
                fi
            fi
        else
            log_info "Skipped: $relative_path from $project_name"
            skipped_dirs+=("$relative_path")
        fi
    done <<< "$bin_dirs"

    # Return status based on results
    if [ ${#failed_dirs[@]} -gt 0 ]; then
        return 1
    fi

    return 0
}

# Main execution function
main() {
    log_info "Starting Go bins clean process..."

    # Parse arguments
    parse_args "$@"

    # Validate base directory
    if [ ! -d "$BASE_DIR" ]; then
        log_error "Directory '$BASE_DIR' does not exist or is not accessible"
        exit 1
    fi

    # Convert to absolute path
    BASE_DIR=$(cd "$BASE_DIR" && pwd)
    log_verbose "Searching for Go projects in: $BASE_DIR"

    # Find all go.mod files, excluding common build directories
    local go_files
    log_verbose "Searching for go.mod files in: $BASE_DIR"
    
    if ! go_files=$(find "$BASE_DIR" -name 'go.mod' -type f \
        -not -path '*/target/*' \
        -not -path '*/.git/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/vendor/*' 2>/dev/null | sort); then
        log_error "Failed to search for go.mod files in $BASE_DIR"
        exit 1
    fi

    if [ -z "$go_files" ]; then
        log_info "No go.mod files found in $BASE_DIR"
        log_verbose "Searched paths: $BASE_DIR (excluding target, .git, node_modules, vendor)"
        exit 0
    fi

    local project_count=$(echo "$go_files" | wc -l)
    log_info "Found $project_count Go project(s)"

    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN MODE - No actual cleaning will be performed"
    fi

    if [ "$FORCE" = true ]; then
        log_info "FORCE MODE - All bin directories will be removed without asking"
    elif [ "$AUTO_YES" = true ]; then
        log_info "AUTO YES MODE - All bin directories will be removed automatically"
    elif [ "$INTERACTIVE" = true ]; then
        log_info "INTERACTIVE MODE - You will be asked for confirmation for each bin directory"
    fi

    # Process projects
    local processed=0
    local failed=0
    local total_files=$(echo "$go_files" | wc -l)
    log_verbose "Starting to process $total_files go.mod files"

    while IFS= read -r go_file; do
        local project_dir=$(dirname "$go_file")
        log_verbose "Processing go.mod file: $go_file"
        log_verbose "Project directory: $project_dir"

        if clean_project "$project_dir"; then
            ((processed++))
            log_verbose "Successfully processed project: $project_dir (processed: $processed)"
        else
            ((failed++))
            log_warning "Failed to process project: $project_dir (failed: $failed)"
        fi
    done <<< "$go_files"
    
    log_verbose "Finished processing all projects. Processed: $processed, Failed: $failed"

    # Generate final report
    echo
    log_info "=== CLEANUP REPORT ==="
    log_success "Projects processed: $processed"
    if [ $failed -gt 0 ]; then
        log_warning "Projects failed: $failed"
        log_info "Check verbose output for details about failed projects"
    fi

    if [ "$DRY_RUN" = true ]; then
        log_warning "This was a dry run. Use without --dry-run to actually clean directories."
    else
        log_success "Go bins cleanup completed successfully!"
    fi
}

# Execute main function
main "$@"
