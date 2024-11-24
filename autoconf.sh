#!/bin/bash

# Logging functions
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $*"
}
success() {
    log "[SUCCESS] $*"
}
err() {
    log "[ERROR] $*"
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

# Calls helper scripts
call_helper() {
    local script="./helpers/$1.sh"
            if [ -x "$script" ]; then
                log "Setting up $1 environment..."
                "$script"
            else
                err "Error: $1.sh script not found or executable in ./helpers."
                exit 2
            fi
}

# Set up traps
trap cleanup INT TERM
trap save_progress HUP

# Setting up logging
LOGFILE="./autoconf_logs-$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1

main () {
    # Validate all helper scripts exist
    for helper in "firsttime" "coding" "hacking" "essentials"; do
        if [ ! -x "./helpers/$helper.sh" ]; then
            err "Error: Required helper script is missing or not executable. Check that coding.sh, essentials.sh, firsttime.sh, and hacking.sh are present and executable"
            exit 1
        fi
    done

    # Check if the script is run with sudo
    if [ "$EUID" -ne 0 ]; then
        err "This script needs root to run. Use 'sudo ./autoconf.sh' and try again."
        exit 1
    fi

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
    success "Environment setup complete!"
    exit 0
}

main
