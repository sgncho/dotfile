#!/usr/bin/env bash

# zellij
tma() {
    zellij attach "$(zellij ls -n | awk 'NS==0 { print $1; exit; }')"
}

tmr() {
    zellij run --in-place "$@"
}

# age
_encrypt_usage() {
    # shellcheck disable=SC2059
    printf "
Encrypts a file or directory using age and zstd, removing the original upon success.

USAGE:
    encrypt <file_or_directory>
    encrypt -h | --help

ARGUMENTS:
    <file_or_directory>    The file or directory to encrypt.

OPTIONS:
    -h, --help             Prints help information.

DEPENDENCIES:
    - age: Required for encryption.
    - zstd: Required for compression.
    - SSH Key: Requires '$HOME/.ssh/id_ed25519.pub' for encryption.

EXAMPLES:
    # Encrypt a single file
    encrypt my_document.txt

    # Encrypt a directory
    encrypt my_project/
"
}

encrypt() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local BLUE='\033[0;34m'
    local NC='\033[0m'
    local ENCRYPT_TARGET

    # Display help if requested
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        _encrypt_usage
        return 0
    fi

    # Check dependencies
    if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
        printf "%b\n" "${RED}Error:${NC} No public SSH key found at $HOME/.ssh/id_ed25519.pub."
        return 1
    fi
    if ! command -v age >/dev/null 2>&1; then
        printf "%b\n" "${RED}Error:${NC} 'age' command not found. Please install 'age' to proceed."
        return 1
    fi
    if ! command -v zstd >/dev/null 2>&1; then
        printf "%b\n" "${RED}Error:${NC} 'zstd' command not found. Please install 'zstd' to proceed."
        return 1
    fi

    # Check for target argument
    if [ -z "$1" ]; then
        printf "%b\n" "${RED}Error:${NC} No target specified."
        printf "\nUsage: encrypt <file_or_directory>\n"
        printf "Run 'encrypt --help' for more details.\n"
        return 1
    fi
    ENCRYPT_TARGET="$1"

    # Encrypt directory
    if [ -d "$ENCRYPT_TARGET" ]; then
        printf "%b\n" "Encrypting directory ${BLUE}${ENCRYPT_TARGET}${NC}"
        local output_file="${ENCRYPT_TARGET%/}.tar.zst.age" # Ensure no trailing slash for output name

        # Use subshell for pipeline to handle errors correctly
        if (set -o pipefail; tar -cf - "$ENCRYPT_TARGET" | zstd -c -T0 | age -R "$HOME/.ssh/id_ed25519.pub" >"$output_file"); then
            rm -rf "$ENCRYPT_TARGET"
            printf "%b\n" "${GREEN}Success:${NC} Directory ${BLUE}${ENCRYPT_TARGET}${NC} encrypted to ${BLUE}${output_file}${NC} and removed."
        else
            printf "%b\n" "${RED}Error:${NC} Failed to encrypt directory ${BLUE}${ENCRYPT_TARGET}${NC} (status: $?)."
            # Attempt to remove potentially incomplete encrypted file
            rm -f "$output_file" >/dev/null 2>&1
            return 1
        fi
    # Encrypt file
    elif [ -f "$ENCRYPT_TARGET" ]; then
        printf "%b\n" "Encrypting file ${BLUE}${ENCRYPT_TARGET}${NC}"
        local output_file="${ENCRYPT_TARGET}.zst.age"

        # Use subshell for pipeline to handle errors correctly
        if (set -o pipefail; zstd -c -T0 "$ENCRYPT_TARGET" | age -R "$HOME/.ssh/id_ed25519.pub" >"$output_file"); then
            rm -f "$ENCRYPT_TARGET"
            printf "%b\n" "${GREEN}Success:${NC} File ${BLUE}${ENCRYPT_TARGET}${NC} encrypted to ${BLUE}${output_file}${NC} and removed."
        else
            printf "%b\n" "${RED}Error:${NC} Failed to encrypt file ${BLUE}${ENCRYPT_TARGET}${NC} (status: $?)."
            # Attempt to remove potentially incomplete encrypted file
            rm -f "$output_file" >/dev/null 2>&1
            return 1
        fi
    # Invalid target
    else
        printf "%b\n" "${RED}Error:${NC} Invalid target ${BLUE}${ENCRYPT_TARGET}${NC}. Must be a file or directory."
        return 1
    fi
}

_decrypt_usage() {
    # shellcheck disable=SC2059
    printf "
Decrypts a file or directory archive previously encrypted with 'encrypt',
removing the encrypted file upon success.

USAGE:
    decrypt <encrypted_file>
    decrypt -h | --help

ARGUMENTS:
    <encrypted_file>    The .zst.age or .tar.zst.age file to decrypt.

OPTIONS:
    -h, --help          Prints help information.

DEPENDENCIES:
    - age: Required for decryption.
    - zstd: Required for decompression.
    - SSH Key: Requires '$HOME/.ssh/id_ed25519' for decryption.

EXAMPLES:
    # Decrypt a single file archive
    decrypt my_document.txt.zst.age

    # Decrypt a directory archive
    decrypt my_project.tar.zst.age
"
}

decrypt() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local BLUE='\033[0;34m'
    local NC='\033[0m'
    local DECRYPT_TARGET

    # Display help if requested
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        _decrypt_usage
        return 0
    fi

    # Check dependencies
    if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        printf "%b\n" "${RED}Error:${NC} No secret SSH key found at $HOME/.ssh/id_ed25519."
        return 1
    fi
    if ! command -v age >/dev/null 2>&1; then
        printf "%b\n" "${RED}Error:${NC} 'age' command not found. Please install 'age' to proceed."
        return 1
    fi
    if ! command -v zstd >/dev/null 2>&1; then
        printf "%b\n" "${RED}Error:${NC} 'zstd' command not found. Please install 'zstd' to proceed."
        return 1
    fi

    # Check for target argument
    if [ -z "$1" ]; then
        printf "%b\n" "${RED}Error:${NC} No target specified."
        printf "\nUsage: decrypt <file.zst.age | file.tar.zst.age>\n"
        printf "Run 'decrypt --help' for more details.\n"
        return 1
    fi
    DECRYPT_TARGET="$1"

    # Check if target exists
    if [ ! -f "$DECRYPT_TARGET" ]; then
        printf "%b\n" "${RED}Error:${NC} Encrypted file ${BLUE}${DECRYPT_TARGET}${NC} does not exist."
        return 1
    fi

    # Decrypt based on file extension
    case "$DECRYPT_TARGET" in
    *.tar.zst.age)
        printf "%b\n" "Decrypting directory archive ${BLUE}${DECRYPT_TARGET}${NC}"

        # Use subshell for pipeline to handle errors correctly
        if (set -o pipefail; age -d -i "$HOME/.ssh/id_ed25519" "$DECRYPT_TARGET" | zstd -d -T0 | tar -xf -); then
            rm "$DECRYPT_TARGET"
            printf "%b\n" "${GREEN}Success:${NC} Archive ${BLUE}${DECRYPT_TARGET}${NC} decrypted and removed."
        else
            printf "%b\n" "${RED}Error:${NC} Failed to decrypt archive ${BLUE}${DECRYPT_TARGET}${NC} (status: $?)."
            # Note: Cannot reliably clean up partially extracted files from tar stream on error
            return 1
        fi
        ;;
    *.zst.age)
        printf "%b\n" "Decrypting file ${BLUE}${DECRYPT_TARGET}${NC}"
        local output_file="${DECRYPT_TARGET%.zst.age}"

        # Check if output file already exists
        if [ -e "$output_file" ]; then
            printf "%b\n" "${RED}Error:${NC} Output file ${BLUE}${output_file}${NC} already exists. Please remove or rename it first."
            return 1
        fi

        # Use subshell for pipeline to handle errors correctly
        if (set -o pipefail; age -d -i "$HOME/.ssh/id_ed25519" "$DECRYPT_TARGET" | zstd -d -T0 -o "$output_file"); then
            rm "$DECRYPT_TARGET"
            printf "%b\n" "${GREEN}Success:${NC} File ${BLUE}${DECRYPT_TARGET}${NC} decrypted to ${BLUE}${output_file}${NC} and removed."
        else
            printf "%b\n" "${RED}Error:${NC} Failed to decrypt file ${BLUE}${DECRYPT_TARGET}${NC} (status: $?)."
            # Attempt to remove potentially incomplete output file
            rm -f "$output_file" >/dev/null 2>&1
            return 1
        fi
        ;;
    *)
        printf "%b\n" "${RED}Error:${NC} Unsupported file type ${BLUE}${DECRYPT_TARGET}${NC}. Expecting *.zst.age or *.tar.zst.age"
        _decrypt_usage # Show usage on unsupported type
        return 1
        ;;
    esac
}
