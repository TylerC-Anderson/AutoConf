#!/bin/bash

# TODO: Check if the script is run with sudo, and exit if not
# Hint: Use the EUID check like in the main script.

# TODO: Update and upgrade the system
# - Run `sudo apt update` and `sudo apt upgrade -y` to ensure the latest software versions.

# TODO: Install core dependencies
# - Install essential tools: curl, wget, git, zsh, build-essential, etc.

# TODO: Set up the default shell
# - Install the desired shell (e.g., Zsh, Fish).
# - Change the default shell for the user (e.g., `chsh -s $(which zsh)`).

# TODO: Configure the shell environment
# - Pull in dotfiles (e.g., `.zshrc`, `.bashrc`, or `.config/fish/config.fish`).
# - Add aliases and environment variables for first-time use.

# TODO: Install Starship Prompt
# - Install Starship and set it up for the default shell.

# TODO: Install a package manager if missing
# - Example: Homebrew for Linux (`https://brew.sh`), especially if you want cross-platform consistency.

# TODO: Install basic productivity tools
# - Tools like tmux, htop, fzf, and ripgrep for better terminal workflows.

# TODO: Configure the terminal emulator (optional)
# - Set up themes, fonts, and configurations for your terminal emulator (e.g., Tilix, Kitty).

# TODO: Install GUI productivity software (optional)
# - Install things like a text editor (VS Code), browsers (Firefox, Chrome), or other GUI tools.

# TODO: Configure Git
# - Set up global user credentials:
#   - `git config --global user.name "Your Name"`
#   - `git config --global user.email "you@example.com"`

# TODO: Install additional user-requested tools
# - Examples:
#   - Language managers (e.g., pyenv for Python, nvm for Node.js).
#   - Programming tools (e.g., Python, Node.js, Docker).

# TODO: Perform final cleanup
# - Remove unused packages with `sudo apt autoremove -y`.
# - Provide a success message or instructions for next steps.
