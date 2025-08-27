#!/usr/bin/env bash

# Copyright (c) 2025 - Cowboy AI, LLC.

# Mathematical Copyright Validation Script
# Provides provable copyright completeness across the repository

set -euo pipefail

# ANSI color codes for mathematical rigor visualization
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Mathematical constants
readonly CANONICAL_COPYRIGHT="Copyright (c) 2025 - Cowboy AI, LLC."
readonly COPYRIGHT_YEAR="2025"
readonly COPYRIGHT_HOLDER="Cowboy AI, LLC."

# File type detection patterns
readonly RUST_PATTERN='\.rs$'
readonly MARKDOWN_PATTERN='\.md$'
readonly NIX_PATTERN='\.nix$'

# Exclusion patterns - files that don't require copyright
readonly EXCLUSION_PATTERNS=(
    "\.lock$"
    "^target/"
    "^result/"
    "^\.direnv/"
    "^\.git/"
    "\.gitignore$"
    "\.gitattributes$"
    "\.png$"
    "\.jpg$"
    "\.jpeg$"
    "\.gif$"
    "\.ico$"
    "Cargo\.lock$"
    "flake\.lock$"
)

# Copyright format templates by file type
get_copyright_format() {
    local file_ext="$1"
    case "$file_ext" in
        "rs")
            echo "/*
 * Copyright (c) 2025 - Cowboy AI, LLC.
 */"
            ;;
        "md")
            echo "<!-- Copyright (c) 2025 - Cowboy AI, LLC. -->"
            ;;
        "nix")
            echo "# Copyright (c) 2025 - Cowboy AI, LLC."
            ;;
        *)
            echo "ERROR: Unknown file type: $file_ext" >&2
            return 1
            ;;
    esac
}

# Extract file extension for mathematical classification
get_file_extension() {
    local filepath="$1"
    echo "${filepath##*.}"
}

# Determine if file is in copyright domain C
is_copyright_required() {
    local filepath="$1"
    
    # Check exclusion patterns first
    for pattern in "${EXCLUSION_PATTERNS[@]}"; do
        if [[ "$filepath" =~ $pattern ]]; then
            return 1  # Excluded from copyright domain
        fi
    done
    
    # Check if file extension requires copyright
    local ext
    ext=$(get_file_extension "$filepath")
    case "$ext" in
        "rs"|"md"|"nix")
            return 0  # In copyright domain
            ;;
        *)
            return 1  # Not in copyright domain
            ;;
    esac
}

# Mathematical copyright detection function
has_valid_copyright() {
    local filepath="$1"
    local ext
    ext=$(get_file_extension "$filepath")
    
    if [[ ! -f "$filepath" ]]; then
        return 1
    fi
    
    # Read first 10 lines to find copyright notice
    local first_lines
    first_lines=$(head -n 10 "$filepath" 2>/dev/null || echo "")
    
    # Define search patterns by file type
    case "$ext" in
        "rs")
            # Look for /* * Copyright (c) 2025 - Cowboy AI, LLC. */
            if echo "$first_lines" | grep -q "Copyright (c) $COPYRIGHT_YEAR - $COPYRIGHT_HOLDER"; then
                return 0
            fi
            # Also accept existing format for now
            if echo "$first_lines" | grep -q "Copyright $COPYRIGHT_YEAR - $COPYRIGHT_HOLDER"; then
                return 0
            fi
            ;;
        "md")
            # Look for <!-- Copyright (c) 2025 - Cowboy AI, LLC. -->
            if echo "$first_lines" | grep -q "Copyright (c) $COPYRIGHT_YEAR - $COPYRIGHT_HOLDER"; then
                return 0
            fi
            ;;
        "nix")
            # Look for # Copyright (c) 2025 - Cowboy AI, LLC.
            if echo "$first_lines" | grep -q "Copyright (c) $COPYRIGHT_YEAR - $COPYRIGHT_HOLDER"; then
                return 0
            fi
            ;;
    esac
    
    return 1
}

# Add copyright notice to file
add_copyright() {
    local filepath="$1"
    local ext
    ext=$(get_file_extension "$filepath")
    
    local copyright_header
    copyright_header=$(get_copyright_format "$ext")
    
    local temp_file
    temp_file=$(mktemp)
    
    # Add copyright header followed by blank line and original content
    echo "$copyright_header" > "$temp_file"
    echo "" >> "$temp_file"
    cat "$filepath" >> "$temp_file"
    
    mv "$temp_file" "$filepath"
    
    echo -e "${GREEN}✓${NC} Added copyright to: $filepath"
}

# Validate single file
validate_file() {
    local filepath="$1"
    local mode="${2:-check}"  # check or fix
    
    if ! is_copyright_required "$filepath"; then
        return 0  # File doesn't need copyright
    fi
    
    if has_valid_copyright "$filepath"; then
        echo -e "${GREEN}✓${NC} Valid copyright: $filepath"
        return 0
    else
        if [[ "$mode" == "fix" ]]; then
            add_copyright "$filepath"
            return 0
        else
            echo -e "${RED}✗${NC} Missing copyright: $filepath"
            return 1
        fi
    fi
}

# Mathematical proof of repository copyright completeness
validate_repository() {
    local mode="${1:-check}"  # check or fix
    local exit_code=0
    local total_files=0
    local copyright_files=0
    local valid_files=0
    local invalid_files=0
    
    echo -e "${BOLD}${BLUE}🔬 SAGE Mathematical Copyright Validation${NC}"
    echo "=========================================="
    echo ""
    
    # Find all files in the repository
    local all_files
    if [[ -d .git ]]; then
        # Git repository - only check tracked and staged files
        all_files=$(git ls-files 2>/dev/null || find . -type f)
    else
        # Not a git repo - check all files
        all_files=$(find . -type f)
    fi
    
    # Process each file
    while IFS= read -r file; do
        total_files=$((total_files + 1))
        
        if is_copyright_required "$file"; then
            copyright_files=$((copyright_files + 1))
            
            if validate_file "$file" "$mode"; then
                valid_files=$((valid_files + 1))
            else
                invalid_files=$((invalid_files + 1))
                exit_code=1
            fi
        fi
    done <<< "$all_files"
    
    echo ""
    echo -e "${BOLD}Mathematical Copyright Analysis:${NC}"
    echo "================================="
    echo -e "Total files analyzed: ${BOLD}$total_files${NC}"
    echo -e "Files requiring copyright: ${BOLD}$copyright_files${NC}"
    echo -e "Files with valid copyright: ${GREEN}$valid_files${NC}"
    echo -e "Files missing copyright: ${RED}$invalid_files${NC}"
    
    if [[ $invalid_files -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}${BOLD}✓ PROOF COMPLETE${NC}: Repository is copyright-complete"
        echo -e "  ∀ f ∈ C : has_copyright(f) = true"
    else
        echo ""
        echo -e "${RED}${BOLD}✗ PROOF FAILED${NC}: Repository copyright is incomplete"
        echo -e "  ∃ f ∈ C : has_copyright(f) = false"
        
        if [[ "$mode" == "check" ]]; then
            echo ""
            echo -e "${YELLOW}Run with --fix to automatically add missing copyrights${NC}"
        fi
    fi
    
    return $exit_code
}

# Validate staged files for git pre-commit hook
validate_staged() {
    local mode="${1:-check}"
    local exit_code=0
    
    echo -e "${BOLD}${BLUE}🔬 SAGE Pre-commit Copyright Validation${NC}"
    echo "======================================="
    echo ""
    
    # Get staged files
    local staged_files
    staged_files=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")
    
    if [[ -z "$staged_files" ]]; then
        echo "No staged files found."
        return 0
    fi
    
    local total_staged=0
    local copyright_staged=0
    local valid_staged=0
    local invalid_staged=0
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        total_staged=$((total_staged + 1))
        
        if is_copyright_required "$file"; then
            copyright_staged=$((copyright_staged + 1))
            
            if validate_file "$file" "$mode"; then
                valid_staged=$((valid_staged + 1))
            else
                invalid_staged=$((invalid_staged + 1))
                exit_code=1
            fi
        fi
    done <<< "$staged_files"
    
    echo ""
    echo -e "${BOLD}Staged Files Copyright Analysis:${NC}"
    echo "==============================="
    echo -e "Total staged files: ${BOLD}$total_staged${NC}"
    echo -e "Staged files requiring copyright: ${BOLD}$copyright_staged${NC}"
    echo -e "Valid staged files: ${GREEN}$valid_staged${NC}"
    echo -e "Invalid staged files: ${RED}$invalid_staged${NC}"
    
    if [[ $invalid_staged -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}${BOLD}✓ COMMIT APPROVED${NC}: All staged files have valid copyright"
    else
        echo ""
        echo -e "${RED}${BOLD}✗ COMMIT BLOCKED${NC}: Staged files missing copyright"
        
        if [[ "$mode" == "check" ]]; then
            echo ""
            echo -e "${YELLOW}Options:${NC}"
            echo "1. Run: git add . && $0 --fix-staged"  
            echo "2. Add copyright manually to failing files"
            echo "3. Exclude files if they shouldn't have copyright"
        fi
    fi
    
    return $exit_code
}

# Command line interface
main() {
    local command="${1:-}"
    
    case "$command" in
        "--help"|"-h")
            echo "SAGE Mathematical Copyright Validator"
            echo ""
            echo "Usage:"
            echo "  $0                    # Check all files"
            echo "  $0 --fix             # Fix all files by adding copyright"
            echo "  $0 --staged          # Check only staged files (pre-commit)"
            echo "  $0 --fix-staged      # Fix staged files and re-stage them"
            echo "  $0 --file <path>     # Check specific file"
            echo "  $0 --fix-file <path> # Fix specific file"
            echo ""
            echo "Mathematical Properties:"
            echo "  Domain C = {f ∈ Files : extension(f) ∈ {.rs, .md, .nix}}"
            echo "  Goal: ∀ f ∈ C : has_copyright(f) = true"
            ;;
        "--fix")
            validate_repository "fix"
            ;;
        "--staged")
            validate_staged "check"
            ;;
        "--fix-staged")
            if validate_staged "fix"; then
                # Re-stage fixed files
                git add -u
                echo -e "${GREEN}Fixed files re-staged for commit${NC}"
            fi
            ;;
        "--file")
            if [[ -n "${2:-}" ]]; then
                validate_file "$2" "check"
            else
                echo "Error: --file requires a file path"
                exit 1
            fi
            ;;
        "--fix-file")
            if [[ -n "${2:-}" ]]; then
                validate_file "$2" "fix"
            else
                echo "Error: --fix-file requires a file path"
                exit 1
            fi
            ;;
        "")
            validate_repository "check"
            ;;
        *)
            echo "Error: Unknown command: $command"
            echo "Use $0 --help for usage information"
            exit 1
            ;;
    esac
}

main "$@"