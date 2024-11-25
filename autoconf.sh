#!/bin/bash

# Base directory for global script calls
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging setup
LOG_DIR="/var/log/autoconf"
mkdir -p "$LOG_DIR"
LOGFILE="$LOG_DIR/autoconf_logs-$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1

# Logging functions
log() {
    echo "[autoconf.sh] $(date +"%Y-%m-%d %H:%M:%S") $*"
}
success() {
    log "[SUCCESS] $*"
}
err() {
    log "[ERROR] $*"
}

# System and script management functions
update_system() {
    # Update the system and cleanup

    log "Running system update and cleanup..."
    if ! apt update && apt upgrade -y && apt autoremove -y; then
        err "System update and cleanup failed. Please check your package manager."
        exit 1
    fi
    success "System update and cleanup completed!"
}
helper_check() {
    # Validate all helper scripts exist

    local helpers_list="$BASE_DIR/config/helperslist.txt"

    if [ ! -f "$helpers_list" ]; then
        err "helperslist.txt not found. Please provide a valid list of helper scripts."
        exit 2
    fi

    if [ ! -s "$helpers_list" ]; then
        err "helperslist.txt is empty. Populate it with the names of required helper scripts."
        exit 2
    fi

    while IFS= read -r helper; do
        if [ -z "$helper" ]; then
            continue  # Skip empty lines
        elif [ ! -x "$BASE_DIR/helpers/$helper.sh" ]; then
            err "Error: Required helper script is missing or not executable. Check that coding.sh, essentials.sh, firsttime.sh, and hacking.sh are present and executable"
            exit 2
        fi
    done < "$helpers_list"
    success "All helper scripts are validated and ready to use."
}
call_helper() {
    # Calls helper scripts

    local script="$BASE_DIR/helpers/$1.sh"
    if [ -x "$script" ]; then
        log "Executing $1 setup..."
        "$script"
    fi
}
interactive_mode() {
    # Guides the user through setup
    log "Entering interactive mode..."
    
    # Input cycle for user options
    while true; do
        # First-time setup
        log "Is this first time setup for a new machine? y/n"
        read -r firsttime

        # Input sanitization
        firsttime=${firsttime,,}     # sets to lowercase
        firsttime=${firsttime:0:1}   # sets to first letter only

        # Input reading and validity check
        if [ "$firsttime" = "y" ]; then
            call_helper "firsttime"
            break   # Valid, we're done here
        elif [ "$firsttime" = "n" ]; then
            success "Skipping first time environment setup..."
            break   # Valid, we're done here
        else 
            err "Invalid. Please enter (y)es or (n)o."
        fi
    done

    # Input cycle for user options
    while true; do
        # Menu for configuration options
        log "Please choose a setup option:"
        log " - 1: Coding"
        log " - 2: Hacking"
        log " - 3: Essentials"
        read -rp "Enter your choice (1-3): " choice

        # Calls the appropriate helper script based on user choice
        if [[ "$choice" =~ ^[1-3]$ ]]; then
            case $choice in
                1) call_helper "coding" ;;
                2) call_helper "hacking" ;;
                3) call_helper "essentials" ;;
            esac
            break   # Valid, we're done here
        else
            err "Invalid. Please enter 1, 2, or 3."
        fi
    done

    # Log success and print to user
    success "Interactive mode complete! Exiting script."
    exit 0
}
help_user() {
    # Displays help message for user

    local help_file="$BASE_DIR/config/help.txt"
    if [ -f "$help_file" ]; then
        cat "$help_file"
        exit 0
    else
        err "Help file not found. Please ensure 'help.txt' is present in the ./config directory."
        exit 2
    fi
}

# Session Management functions
# TODO: These are stubs; define cleanup and progress-saving functions
cleanup() {
    log "Session closed. Nothing to save yet. Stub function called."
    # TODO: Add cleanup logic if necessary
    exit 1
}
save_progress() {
    log "Session closed. Nothing to save yet. Stub function called."
    # TODO: Add save progress logic if necessary
    #log "Saving current progress to /tmp/progress.log..."
    #log "Progress saved at $(date)" > /tmp/progress.log
    exit 1
}

# Set up traps
trap cleanup INT TERM
trap save_progress HUP

main () {

    # Check if the script is run with sudo
    if [ "$EUID" -ne 0 ]; then
        err "AutoConf needs root to run. Use 'sudo $BASE_DIR/autoconf.sh' and try again."
        exit 1
    fi

    if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
        log "No arguments provided. Displaying help."
        help_user
    fi

    update_system
    helper_check

    for arg in "$@"; do
        if [[ "$arg" == "--interactive" || "$arg" == "-i" ]]; then
            log "Starting interactive mode..."
            interactive_mode
            success "Environment setup complete!"
            exit 0  # Exit after running interactive mode
        fi
    done

    while getopts ":ckeh" opt; do
        case $opt in
            c) call_helper "coding" ;;
            k) call_helper "hacking" ;;
            e) call_helper "essentials" ;;
            h) help_user ;;
            *) err "Invalid option: -$OPTARG" >&2; exit 1 ;;
        esac
    done

    success "Environment setup complete!"
}

main "$@"
