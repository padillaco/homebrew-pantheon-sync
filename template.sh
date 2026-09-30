#!/usr/bin/env bash

## Description: Sync the database and files from a specified Pantheon environment to the local DDEV environment. This script uses the `pantheon-sync` command-line tool to perform the synchronization.
## Usage: sync
## Example: "ddev sync --env=live --db"
## Flags: [{"Name":"env","Shorthand":"e","Usage":"The environment to pull from (\"dev\", \"test\", \"live\", or the multidev environment slug)","Type":"string","DefValue":"live"},{"Name":"db","Usage":"Sync the database only","Type":"bool","DefValue":"0"},{"Name":"database","Usage":"Sync the database only (alias for --db)","Type":"bool","DefValue":"0"},{"Name":"files","Usage":"Sync the files only","Type":"bool","DefValue":"0"},{"Name":"verbose","Shorthand":"v","Usage":"Enable verbose output","Type":"bool","DefValue":"0"}]

# ---------------------------- REQUIREMENTS & USAGE ----------------------------

# Requirements:
#   - Docker: https://docs.docker.com/engine/install/
#   - DDEV: https://ddev.com/get-started/
#   - Homebrew: https://brew.sh/
#   - Terminus (by Pantheon): https://docs.pantheon.io/terminus/install
#
# 1. Set the website configuration values in the `pantheon-sync` command below.
#
# 2. Run `pantheon-sync --help` to see command usage, available flags,
#    and important notes.
#
# 3. Run `ddev sync` to sync the database and files from the default environment.
#    Use flags to customize the sync behavior:
#
#      --env=<env>   Pull from a specific environment: "dev", "test", "live",
#                    or a multidev environment slug
#                    e.g., `ddev sync --env=dev`
#      --db          Sync the database only
#                    e.g., `ddev sync --db`
#      --files       Sync the files only
#                    e.g., `ddev sync --files`
#      --verbose     Enable verbose output for debugging
#                    e.g., `ddev sync --verbose`

# ---------------------------- DEFAULT FLAG VALUES -----------------------------

ENV="live"
SYNC="all"
VERBOSE=0

# -------------------------- WEBSITE CONFIGURATION ----------------------------

# The name of the Pantheon site, used for identification.
SITE_NAME=""

# The Pantheon site slug — the unique identifier found in any Pantheon environment URL.
# e.g., "example" if the URL is https://live-example.pantheonsite.io
SITE_SLUG=""

# The Pantheon site ID, found in the Pantheon dashboard URL for the site.
SITE_ID=""

# Custom domains to search/replace for the live environment.
# Use a comma-separated list to specify multiple domains.
# Note: the Pantheon environment URL ({env}-{site-slug}.pantheonsite.io) is auto-added.
LIVE_SOURCE_DOMAINS=""

# The replacement domains for the live environment (the local DDEV domains).
# Use a comma-separated list to match the order of LIVE_SOURCE_DOMAINS.
LIVE_REPLACEMENT_DOMAINS=""

# Custom domains for the test environment (optional, falls back to live domains if not set).
# Use a comma-separated list to specify multiple domains.
TEST_SOURCE_DOMAINS=""

# The replacement domains for the test environment (the local DDEV domains).
# Use a comma-separated list to match the order of TEST_SOURCE_DOMAINS.
TEST_REPLACEMENT_DOMAINS=""

# Custom domains for the dev environment (optional, falls back to live domains if not set).
# Use a comma-separated list to specify multiple domains.
DEV_SOURCE_DOMAINS=""

# The replacement domains for the dev environment (the local DDEV domains).
# Use a comma-separated list to match the order of DEV_SOURCE_DOMAINS.
DEV_REPLACEMENT_DOMAINS=""

# Custom domains for other environments, e.g. multidev (optional, falls back to live domains if not set).
# Use a comma-separated list to specify multiple domains.
OTHER_SOURCE_DOMAINS=""

# The replacement domains for other environments (the local DDEV domains).
# Use a comma-separated list to match the order of OTHER_SOURCE_DOMAINS.
OTHER_REPLACEMENT_DOMAINS=""

# ------------------------------------------------------------------------------

for arg in "$@"; do
  case $arg in
    -e=*|--env=*)
      ENV="${arg#*=}"
      ;;

    --db|--database)
      SYNC="DB"
      ;;

    --files)
      SYNC="files"
      ;;

    -v|--verbose)
      VERBOSE=1
      ;;

    -*|--*)
      echo -e "\033[0;31mUnknown option $arg\033[0m"
      exit 1
      ;;
  esac
done

pantheon-sync \
  --site-name="$SITE_NAME" \
  --site-slug="$SITE_SLUG" \
  --site-id="$SITE_ID" \
  --live-source-domains="$LIVE_SOURCE_DOMAINS" \
  --live-replacement-domains="$LIVE_REPLACEMENT_DOMAINS" \
  --test-source-domains="$TEST_SOURCE_DOMAINS" \
  --test-replacement-domains="$TEST_REPLACEMENT_DOMAINS" \
  --dev-source-domains="$DEV_SOURCE_DOMAINS" \
  --dev-replacement-domains="$DEV_REPLACEMENT_DOMAINS" \
  --other-source-domains="$OTHER_SOURCE_DOMAINS" \
  --other-replacement-domains="$OTHER_REPLACEMENT_DOMAINS" \
  --env="$ENV" \
  --sync="$SYNC" \
  --verbose=$VERBOSE
