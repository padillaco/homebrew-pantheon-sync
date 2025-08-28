#!/usr/bin/env bash

## Description: Sync the database and files from a specified Pantheon environment to the local DDEV environment. This script uses the `pantheon-sync` command-line tool to perform the synchronization.
## Usage: sync
## Example: "ddev sync --env=live"
## Flags: [{"Name":"env","Shorthand":"e","Usage":"The environment to pull from (\"dev\", \"test\", or \"live\")","Type":"string","DefValue":"live"},{"Name":"verbose","Shorthand":"v","Usage":"Enable verbose output","Type":"bool","DefValue":"0"}]

# --------------------------- SETUP INSTRUCTIONS ---------------------------

# Requirements:
#   - Docker: https://docs.docker.com/engine/install/
#   - DDEV: https://ddev.com/get-started/
#   - Homebrew: https://brew.sh/
#   - Terminus (by Pantheon): https://docs.pantheon.io/terminus/install
#
# 1. Edit the configuration below to set the Pantheon site name, slug,
#    ID, environment URLs, and default environment to pull from.
#
# 2. Run `pantheon-sync --help` to see command usage, available flags,
#    and important notes. If `pantheon-sync` is not installed, running
#    `ddev sync`, as described below, will install it using Homebrew.
#
# 3. Run `ddev sync` to pull the database and files from the live Pantheon
#    environment into the local DDEV environment, or specify a different
#    environment using the `--env` flag (e.g., `ddev sync --env=dev`).

# ----------------------------- CONFIGURATION ------------------------------

# The name of the Pantheon site, which is used for identification
SITE_NAME=""
# The Pantheon site slug, which is the unique identifier for the site,
# which can be found in any Pantheon environment URL for the site
# e.g., https://live-example.pantheonsite.io
SITE_SLUG=""
# The Pantheon site ID, which can be found in the Pantheon dashboard
# URL for the site
SITE_ID=""
# The Pantheon live environment URL. Use a comma-separated
# list to specify multiple/alternative domains
LIVE_DOMAIN=""
# The Pantheon test environment URL. Use a comma-separated
# list to specify multiple/alternative domains
TEST_DOMAIN=""
# The Pantheon development environment URL. Use a comma-separated
# list to specify multiple/alternative domains
DEV_DOMAIN=""
# The DDEV domain for the local development environment
DDEV_DOMAIN=""
# The default Pantheon environment to pull from
ENV="live"
# Enables verbose output for debugging purposes
VERBOSE=0

# --------------------------- END CONFIGURATION ----------------------------

while [[ $# -gt 0 ]]; do
  case $1 in
    -e=*|--env=*)
      ENV="${1#*=}"
      shift
      ;;

    -v|--verbose)
      VERBOSE=1
      shift
      ;;

    -*|--*)
      echo -e "\033[0;31mUnknown option $1\033[0m"
      exit 0
      ;;

    *)
      shift # past argument
      ;;
  esac
done

# Check if Homebrew is installed
# If not, prompt the user to install it
if ! command -v brew >/dev/null 2>&1; then
  echo -e "\033[0;36mHomebrew is required to run this command. See https://brew.sh/ for installation instructions.\033[0m"
  exit 1
fi

# Check if pantheon-sync is installed
# If not, install it using Homebrew
if ! command -v pantheon-sync >/dev/null 2>&1; then
  echo -e "\033[0;33mpantheon-sync is required to run this command.\033[0m\n"
  echo "Installing pantheon-sync using Homebrew..."
  echo -e "\033[0;36m>\033[0m brew tap padillaco/formulas"
  echo -e "\033[0;36m>\033[0m brew install pantheon-sync\n"

  brew tap padillaco/formulas
  brew install pantheon-sync

  echo -e "\n"
  sleep 1
fi

# Run `pantheon-sync --help` to see command usage and available flags
pantheon-sync \
  --site-name="$SITE_NAME" \
  --site-slug="$SITE_SLUG" \
  --site-id="$SITE_ID" \
  --env="$ENV" \
  --live-domain="$LIVE_DOMAIN" \
  --test-domain="$TEST_DOMAIN" \
  --dev-domain="$DEV_DOMAIN" \
  --ddev-domain="$DDEV_DOMAIN" \
  --verbose=$VERBOSE
