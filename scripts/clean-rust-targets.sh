#!/bin/bash

# Rust Targets Clean Script
# Purpose: Clean Cargo build artifacts (target directories) from all Rust projects in the current directory tree

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
Rust Targets Clean Script

USAGE:
    $0 [OPTIONS] [BASE_DIRECTORY]

DESCRIPTION:
    Clean Cargo build artifacts from all Rust projects in the specified directory tree.
    Only processes directories that contain both Cargo.toml and .git (Git repositories).

ARGUMENTS:
    BASE_DIRECTORY      Directory to search for Rust projects (default: current directory)

OPTIONS:
    -v, --verbose       Enable verbose output
    -d, --dry-run       Show what would be done without executing
    -h, --help          Show this help message

EXAMPLES:
    $0                          # Clean all Rust projects in current directory
    $0 /path/to/projects        # Clean all Rust projects in /path/to/projects
    $0 --verbose --dry-run      # Show what would be cleaned in current directory
    $0 --dry-run /path/to/projects  # Show what would be cleaned in /path/to/projects
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

# Check if a directory is a Cargo workspace root
is_workspace_root() {
    local dir="$1"
    if [ -f "$dir/Cargo.toml" ]; then
        # Check if Cargo.toml contains [workspace] section (exact match)
        if grep -q "^\[workspace\]" "$dir/Cargo.toml" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Check if a directory is a workspace member (not root)
is_workspace_member() {
    local dir="$1"
    if [ -f "$dir/Cargo.toml" ]; then
        # Check if this Cargo.toml references workspace (is a member)
        if grep -q "\.workspace\s*=" "$dir/Cargo.toml" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Find the workspace root for a given directory (limited search)
find_workspace_root() {
    local current_dir="$1"
    local original_dir="$current_dir"
    local search_depth=0
    local max_depth=10  # Limit search depth for performance

    while [ "$current_dir" != "/" ] && [ -n "$current_dir" ] && [ $search_depth -lt $max_depth ]; do
        if is_workspace_root "$current_dir"; then
            echo "$current_dir"
            return 0
        fi
        current_dir=$(dirname "$current_dir")
        ((search_depth++))
    done

    # If no workspace found, return the original directory
    echo "$original_dir"
}

# Clean a single project
clean_project() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")

    log_verbose "Processing project: $project_name in $project_dir"

    # Find the actual workspace root
    local workspace_root=$(find_workspace_root "$project_dir")
    local workspace_name=$(basename "$workspace_root")

    # Check if the workspace root is a Git repository
    if [ ! -d "$workspace_root/.git" ]; then
        log_verbose "Skipping $project_name: workspace root '$workspace_name' is not a Git repository"
        return 0
    fi

    # Only process if this is the workspace root (avoid processing subdirectories multiple times)
    if [ "$project_dir" != "$workspace_root" ]; then
        log_verbose "Skipping $project_name: will be processed as part of workspace '$workspace_name'"
        return 0
    fi

    # Show target size if it exists, but process regardless
    local target_size=""
    if [ -d "$workspace_root/target" ]; then
        local size
        if size=$(du -sh "$workspace_root/target" 2>/dev/null | cut -f1); then
            target_size=" (target size: $size)"
        else
            target_size=" (target size: unknown)"
        fi
    fi

    if is_workspace_root "$workspace_root"; then
        log_info "Cleaning workspace $workspace_name$target_size"
    else
        log_info "Cleaning project $workspace_name$target_size"
    fi

    if [ "$DRY_RUN" = true ]; then
        if is_workspace_root "$workspace_root"; then
            log_success "Would clean workspace: $workspace_name"
        else
            log_success "Would clean project: $workspace_name"
        fi
    else
        if cd "$workspace_root" && cargo clean; then
            if is_workspace_root "$workspace_root"; then
                log_success "Cleaned workspace: $workspace_name"
            else
                log_success "Cleaned project: $workspace_name"
            fi
        else
            log_error "Failed to clean: $workspace_name"
            return 1
        fi
    fi
}

# Main execution function
main() {
    log_info "Starting Rust targets clean process..."

    # Parse arguments
    parse_args "$@"

    # Validate base directory
    if [ ! -d "$BASE_DIR" ]; then
        log_error "Directory '$BASE_DIR' does not exist or is not accessible"
        exit 1
    fi

    # Convert to absolute path
    BASE_DIR=$(cd "$BASE_DIR" && pwd)
    log_verbose "Searching for Rust projects in: $BASE_DIR"

    # Find all Cargo.toml files, excluding common build directories
    local cargo_files
    log_verbose "Searching for Cargo.toml files in: $BASE_DIR"
    
    if ! cargo_files=$(find "$BASE_DIR" -name 'Cargo.toml' -type f \
        -not -path '*/target/*' \
        -not -path '*/.git/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/vendor/*' 2>/dev/null | sort); then
        log_error "Failed to search for Cargo.toml files in $BASE_DIR"
        exit 1
    fi

    if [ -z "$cargo_files" ]; then
        log_info "No Cargo.toml files found in $BASE_DIR"
        log_verbose "Searched paths: $BASE_DIR (excluding target, .git, node_modules, vendor)"
        exit 0
    fi

    local project_count=$(echo "$cargo_files" | wc -l)
    log_info "Found $project_count Rust project(s)"

    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN MODE - No actual cleaning will be performed"
    fi

    # Process projects
    local cleaned=0
    local skipped=0
    local failed=0
    local total_files=$(echo "$cargo_files" | wc -l)
    log_verbose "Starting to process $total_files Cargo.toml files"

    while IFS= read -r cargo_file; do
        local project_dir=$(dirname "$cargo_file")
        local workspace_root=$(find_workspace_root "$project_dir")
        log_verbose "Processing Cargo.toml file: $cargo_file"
        log_verbose "Project directory: $project_dir"
        log_verbose "Workspace root: $workspace_root"

        # Skip if this is a workspace member (not root)
        if is_workspace_member "$project_dir"; then
            log_verbose "Skipping $project_dir: is a workspace member"
            continue
        fi

        # Only process if this is the workspace root (avoid double counting)
        if [ "$project_dir" = "$workspace_root" ]; then
            # Check if the workspace root is a Git repository
            if [ -d "$workspace_root/.git" ]; then
                # Process regardless of target directory existence (cargo clean works without target/)
                if clean_project "$project_dir"; then
                    ((cleaned++))
                    log_verbose "Successfully processed project: $project_dir (processed: $cleaned)"
                else
                    ((failed++))
                    log_warning "Failed to process project: $project_dir (failed: $failed)"
                fi
            else
                log_verbose "Skipping $workspace_root: not a Git repository"
                ((skipped++))
            fi
        else
            log_verbose "Skipping $project_dir: not the workspace root"
        fi
    done <<< "$cargo_files"
    
    log_verbose "Finished processing all projects. Processed: $cleaned, Skipped: $skipped, Failed: $failed"

    # Generate final report
    echo
    log_info "=== CLEANUP REPORT ==="
    log_success "Projects cleaned: $cleaned"
    log_info "Projects skipped: $skipped"
    if [ $failed -gt 0 ]; then
        log_warning "Projects failed: $failed"
        log_info "Check verbose output for details about failed projects"
    fi

    if [ "$DRY_RUN" = true ]; then
        log_warning "This was a dry run. Use without --dry-run to actually clean targets."
    else
        log_success "Rust targets cleanup completed successfully!"
    fi
}

# Execute main function
main "$@"
