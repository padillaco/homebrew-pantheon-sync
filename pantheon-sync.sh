#!/usr/bin/env bash

# Syncs the database and files from a specified Pantheon environment.

# Command Example: pantheon-sync --site-name=MySite --site-slug=my-site --site-id=7acab2d5-c574-4c73-9baf-d9ec1e17abc3 --ddev-domain=my-site.ddev.site --dev-domain=dev.mysite.com --test-domain=staging.mysite.com --live-domain=mysite.com --env=live

# Required Flags:
#   --site-name: The name of the site on the Pantheon dashboard (e.g., "My Site")
#   --site-slug: The slug of the site, which is found in the environment URL https://dev-site-slug.pantheonsite.io (e.g., "my-site")
#   --site-id: The unique ID of the site (e.g., "7acab2d5-c574-4c73-9baf-d9ec1e17abc3")
#   --env: The environment to pull from ("dev", "test", or "live")
#   --ddev-domain: The DDEV domain for the site (e.g., "my-site.ddev.site")
#   --dev-domain: The development domain for the site. Only required if pulling from the dev environment.
#   --test-domain: The test/staging domain for the site. Only required if pulling from the test environment.
#   --live-domain: The live domain for the site. Only required if pulling from the live environment.

# Optional Flags:
#   --ddev-project-root: The root directory of the DDEV project. Defaults to the $DDEV_APPROOT environment variable.
#   --version: The version of the script.

VERSION="0.2.0"
DDEV_PROJECT_ROOT="$DDEV_APPROOT"

while [[ $# -gt 0 ]]; do
  case $1 in
    --site-name=*)
      SITE_NAME="${1#*=}"
      shift
      ;;

    --site-slug=*)
      SITE_SLUG="${1#*=}"
      shift
      ;;

    --site-id=*)
      SITE_ID="${1#*=}"
      shift
      ;;

    --ddev-domain=*)
      DDEV_DOMAIN="${1#*=}"
      shift
      ;;

    --dev-domain=*)
      DEV_DOMAIN="${1#*=}"
      shift
      ;;

    --test-domain=*)
      TEST_DOMAIN="${1#*=}"
      shift
      ;;

    --live-domain=*)
      LIVE_DOMAIN="${1#*=}"
      shift
      ;;

    --env=*)
      ENV="${1#*=}"
      shift
      ;;

    --ddev-project-root=*)
      DDEV_PROJECT_ROOT="${1#*=}"
      shift
      ;;

    --version)
      echo "pantheon-sync v$VERSION"
      exit 0
      ;;

    --help)
      echo -e "Usage: pantheon-sync [flags]\n"
      echo "Flags:"
      echo "  --site-name             The name of the site on the Pantheon dashboard (e.g., \"My Site\")"
      echo "  --site-slug             The slug of the site, which is found in the environment URL https://dev-site-slug.pantheonsite.io (e.g., \"my-site\")"
      echo "  --site-id               The unique ID of the site (e.g., \"7acab2d5-c574-4c73-9baf-d9ec1e17abc3\")"
      echo "  --env                   The environment to pull from (\"dev\", \"test\", or \"live\")"
      echo "  --ddev-domain           The DDEV domain for the site (e.g., \"my-site.ddev.site\")"
      echo "  --dev-domain            The development domain for the site. Only required if pulling from the dev environment."
      echo "  --test-domain           The test/staging domain for the site. Only required if pulling from the test environment."
      echo "  --live-domain           The live domain for the site. Only required if pulling from the live environment."
      echo "  --ddev-project-root     The root directory of the DDEV project. Defaults to the \$DDEV_APPROOT environment variable."
      echo "  --version               Shows the version of the script."
      echo "  --help                  Shows this help message."
      exit 0
      ;;

    -*|--*)
      echo -e "\033[0;31mUnknown option $1\033[0m"
      exit 1
      ;;

    *)
      shift # past argument
      ;;
  esac
done

if [ -z "$DDEV_PROJECT_ROOT" ] || [ ! -e "$DDEV_PROJECT_ROOT" ]; then
  echo -e "\033[0;31mThe DDEV project root is not set or does not exist. Make sure the DDEV site is running if you haven't specified the project root using the --ddev-project-root flag.\033[0m"
  exit 1
fi

cd "$DDEV_PROJECT_ROOT"

if [[ "$ENV" == "dev" ]]; then
  if [ -z "$DEV_DOMAIN" ]; then
    echo -e "\033[0;31mPlease provide a development domain using the --dev-domain flag.\033[0m"
    exit 1
  fi

  SOURCE_ENV_DOMAIN=$DEV_DOMAIN
elif [[ "$ENV" == "test" ]]; then
  if [ -z "$TEST_DOMAIN" ]; then
    echo -e "\033[0;31mPlease provide a staging domain using the --test-domain flag.\033[0m"
    exit 1
  fi

  SOURCE_ENV_DOMAIN=$TEST_DOMAIN
elif [[ "$ENV" == "live" ]]; then
  if [ -z "$LIVE_DOMAIN" ]; then
    echo -e "\033[0;31mPlease provide a live domain using the --live-domain flag.\033[0m"
    exit 1
  fi

  SOURCE_ENV_DOMAIN=$LIVE_DOMAIN
else
  echo -e "\033[0;31mInvalid environment specified. Use 'dev', 'test', or 'live'.\033[0m"
  exit 1
fi

echo -e "Syncing database and files from the \033[0;36m$SITE_NAME $ENV\033[0m environment..."
echo -e "Creating database backup... \033[0;36m(keeping for 1 day)\033[0m"

# Create a backup of the remote environment's database
terminus backup:create --element=database --keep-for=1 -- $SITE_SLUG.$ENV

TEMP_DIR="$DDEV_APPROOT/.ddev/.tmp"

# Create a temporary directory if it doesn't exist
if [ ! -d "$TEMP_DIR" ]; then
  mkdir -p "$TEMP_DIR"
fi

BACKUP_DATE=$(date -u +"%Y-%m-%dT%H-%M-%S")
DATABASE_FILEPATH="$TEMP_DIR/$SITE_SLUG-$ENV-$BACKUP_DATE-UTC-database.sql.gz"

terminus backup:get --element=database --to=$DATABASE_FILEPATH -- $SITE_SLUG.$ENV

if [ ! -e "$DATABASE_FILEPATH" ]; then
  echo -e "\033[0;31mFailed to download database backup. Please check your Terminus configuration and try again.\033[0m"
  exit 1
fi

ddev import-db --file="$DATABASE_FILEPATH"

# Remove the temporary folder and its contents
rm -rf "$TEMP_DIR"

echo -e "Replacing URLs in the database from \033[0;36m$SOURCE_ENV_DOMAIN\033[0m to \033[0;36m$DDEV_DOMAIN\033[0m..."

DB_SEARCH_REPLACE_OUTPUT=$(ddev wp search-replace $SOURCE_ENV_DOMAIN $DDEV_DOMAIN --url=$SOURCE_ENV_DOMAIN --all-tables-with-prefix --skip-columns=guid --skip-plugins --skip-themes)

if [[ "$DB_SEARCH_REPLACE_OUTPUT" == *"Error"* ]]; then
  echo "$DB_SEARCH_REPLACE_OUTPUT"
  exit 0
fi

echo "Flushing the WordPress cache..."

# Flush the WordPress cache to ensure all changes are applied
# This command uses the DDEV WP CLI to flush the cache for the specified URL
# The --skip-plugins and --skip-themes flags are used to avoid running any plugins
# or themes that might interfere with the cache flush process
ddev wp cache flush --url=$DDEV_DOMAIN --skip-plugins --skip-themes

echo -e "\nChecking for files to sync..."

FILES_SOURCE=$ENV.$SITE_ID@appserver.$ENV.$SITE_ID.drush.in:files/
FILES_DESTINATION=$DDEV_APPROOT/wp-content/uploads/

# Sync the files from the remote environment to the local uploads folder
#
# rsync flags used:
# 
# -r: recursive
# -L: copy symlinks as if they were normal files
# -v: verbose
# -4: use IPv4 addresses only
# -n: dry run (perform a trial run with no changes made)
# -z: compress file data during the transfer
# --ignore-existing: skip files that already exist on the destination
# --copy-unsafe-links: transforms symlinks into files when the symlink target is outside of the tree being copied
# --size-only: skip files that match in size
# --progress: show progress during transfer
# -e: specify the remote shell to use (in this case, SSH on port 2222)
#
# For full rsync flag usage and definitions, see: https://linux.die.net/man/1/rsync

# Count total files to sync (excluding already existing files)
TOTAL_FILES_TO_SYNC=$(rsync -rLv4n --stats --ignore-existing --copy-unsafe-links --size-only -e 'ssh -p 2222' "$FILES_SOURCE" "$FILES_DESTINATION" | gawk '/^Transfer starting:/{flag=1;next}/sent [0-9]+ bytes/{flag=0}flag' | grep -v '^[[:space:]]*$' | grep -v '/$' | grep -v 'Skip existing' | wc -l | xargs)

SYNC_COMPLETE_NEW_LINE="\n"

if [ "$TOTAL_FILES_TO_SYNC" -gt 0 ]; then
  echo -e "Syncing \033[0;36m$TOTAL_FILES_TO_SYNC\033[0m files..."

  SYNCED=0
  TOTAL_MEGABYTES=0
  PROGRESS_BAR_WIDTH=40
  SYNC_COMPLETE_NEW_LINE="\n\n"

  # Run rsync and parse output
  rsync -rLv4z --progress --ignore-existing --copy-unsafe-links --size-only -e 'ssh -p 2222' "$FILES_SOURCE" "$FILES_DESTINATION" 2>&1 | \
  while IFS= read -r line; do
    # Detect lines that indicate a file has finished transferring
    if [[ "$line" == *"100%"* ]]; then
      ((SYNCED++))

      BYTES=$(echo "$line" | awk '{print $1}' | xargs)
      MEGABYTES=$(awk "BEGIN {printf \"%.2f\", $BYTES/1000000}")
      TOTAL_MEGABYTES=$(awk "BEGIN {printf \"%.2f\", $TOTAL_MEGABYTES + $MEGABYTES}")
      PERCENT_COMPLETE=$((SYNCED * 100 / TOTAL_FILES_TO_SYNC))

      COMPLETE_BAR_COUNT=$((PERCENT_COMPLETE * PROGRESS_BAR_WIDTH / 100))

      if [ $COMPLETE_BAR_COUNT -gt 0 ]; then
        COMPLETE_BARS=$(printf "%0.s█" $(seq 1 $COMPLETE_BAR_COUNT))
      else
        COMPLETE_BARS=""
      fi

      INCOMPLETE_BAR_COUNT=$((PROGRESS_BAR_WIDTH - COMPLETE_BAR_COUNT))

      if [ $INCOMPLETE_BAR_COUNT -gt 0 ]; then
        INCOMPLETE_BARS=$(printf "%0.s░" $(seq 1 $INCOMPLETE_BAR_COUNT))
      else
        INCOMPLETE_BARS=""
      fi

      printf "\r%s%s %d%% %.2fMB (%d/%d)" "$COMPLETE_BARS" "$INCOMPLETE_BARS" "$PERCENT_COMPLETE" "$TOTAL_MEGABYTES" "$SYNCED" "$TOTAL_FILES_TO_SYNC"
    fi
  done
else
  echo -e "\033[0;32mYou're all caught up! No files to sync.\033[0m"
fi

echo -e "$SYNC_COMPLETE_NEW_LINE\e[1m\033[0;32mSync complete\033[0m\033[0m"
