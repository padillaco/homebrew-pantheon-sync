#!/usr/bin/env bash

# Syncs the database and files from a specified Pantheon environment.

# Command Example: pantheon-sync --site-name="My Site" --site-slug=my-site --site-id=7acab2d5-c574-4c73-9baf-d9ec1e17abc3 --env=live --live-domain=mysite.com --test-domain=staging.mysite.com --dev-domain=dev.mysite.com --ddev-domain=my-site.ddev.site

# Flags:
#   --site-name             The name of the site on the Pantheon dashboard (e.g., "My Site").
#   --site-slug             The slug of the site, which is found in the Pantheon environment URL (e.g., "my-site").
#   --site-id               The unique ID of the site (e.g., "7acab2d5-c574-4c73-9baf-d9ec1e17abc3").
#   --env                   The environment to pull from ("dev", "test", or "live").
#   --live-domain           One or more live domains for the site. See the note below for details.
#   --test-domain           One or more test/staging domains for the site. See the note below for details.
#   --dev-domain            One or more development domains for the site. See the note below for details.
#   --ddev-domain           One or more DDEV domains for the site. See the note below for details.
#   --verbose               Enables verbose output for debugging purposes.
#   --version               Shows the version of the script.
#   --update                Updates the "pantheon-sync" homebrew formula.
#   --help                  Shows command usage and available flags.

# Note for Domain URLs

# 1. To specify multiple domains for an environment, provide a comma-separated list of domains within a single flag. For example:

#   --dev-domain=dev1.example.com,dev2.example.com

# 2. Each environment domain flag must have the same number of domains, and in the same order, as the other environment domain flags, to ensure that the wp search-replace command can replace each source domain with the correct DDEV domain.

# For example, if you have two different domains for each environment on Pantheon (e.g., the default Pantheon environment URL, and the custom domain), and the site is a multisite with an additional domain (e.g., a blog site), you would specify all 3 domains for each environment like this:

#   --live-domain=live-example.pantheonsite.io,example.com,blog.example.com
#   --test-domain=test-example.pantheonsite.io,staging.example.com,staging.blog.example.com
#   --dev-domain=dev-example.pantheonsite.io,dev.example.com,dev.blog.example.com
#   --ddev-domain=example.ddev.site,example.ddev.site,blog.example.ddev.site

VERSION="0.4.6"
DDEV_DOMAINS=()
DEV_DOMAINS=()
TEST_DOMAINS=()
LIVE_DOMAINS=()
VERBOSE=0

extract_domains() {
  local input="$1"
  local -n output_array=$2
  IFS=',' read -ra DOMAINS <<< "$input"
  for domain in "${DOMAINS[@]}"; do
    trimmed_domain="$(echo "$domain" | xargs)"
    output_array+=("$trimmed_domain")
  done
}

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

    --env=*)
      ENV="${1#*=}"
      shift
      ;;

    --live-domain=*)
      extract_domains "${1#*=}" LIVE_DOMAINS
      shift
      ;;

    --test-domain=*)
      extract_domains "${1#*=}" TEST_DOMAINS
      shift
      ;;

    --dev-domain=*)
      extract_domains "${1#*=}" DEV_DOMAINS
      shift
      ;;

    --ddev-domain=*)
      extract_domains "${1#*=}" DDEV_DOMAINS
      shift
      ;;

    --verbose=*)
      VERBOSE=${1#*=}
      shift
      ;;
    
    --verbose)
      VERBOSE=1
      shift
      ;;
    
    --update)
      brew uninstall pantheon-sync wpengine-sync
      brew untap padillaco/formulas
      brew tap padillaco/formulas
      brew install pantheon-sync wpengine-sync
      exit 0
      ;;

    --version)
      echo "pantheon-sync version $VERSION"
      exit 0
      ;;

    --help)
      echo -e "Usage: pantheon-sync [flags]\n"
      echo "Flags:"
      echo -e "  --site-name             The name of the site on the Pantheon dashboard (e.g., \"My Site\")."
      echo -e "  --site-slug             The slug of the site, which is found in the Pantheon environment URL (e.g., \"my-site\")."
      echo -e "  --site-id               The unique ID of the site (e.g., \"7acab2d5-c574-4c73-9baf-d9ec1e17abc3\")."
      echo -e "  --env                   The environment to pull from (\"dev\", \"test\", or \"live\")."
      echo -e "  --live-domain           One or more live domains for the site. See the note below for details."
      echo -e "  --test-domain           One or more test/staging domains for the site. See the note below for details."
      echo -e "  --dev-domain            One or more development domains for the site. See the note below for details."
      echo -e "  --ddev-domain           One or more DDEV domains for the site. See the note below for details."
      echo -e "  --verbose               Enables verbose output for debugging purposes."
      echo -e "  --version               Shows the version of the script."
      echo -e "  --update                Updates the \"pantheon-sync\" homebrew formula."
      echo -e "  --help                  Shows command usage and available flags."
      echo -e "\n\033[1m\033[4m\033[33mNote for Domain URLs\033[0m"
      echo -e "\n\033[1m\033[33m1.\033[0m To specify multiple domains for an environment, provide a comma-separated list of domains within a single flag. For example:"
      echo -e "\n  --dev-domain=\033[36mdev1.example.com\033[0m,\033[36mdev2.example.com\033[0m"
      echo -e "\n\033[1m\033[33m2.\033[0m Each environment domain flag must have the same number of domains, and in the same order, as the other environment domain flags, to ensure that the \033[36mwp search-replace\033[0m command can replace each source domain with the correct DDEV domain."
      echo -e "\nFor example, if you have two different domains for each environment on Pantheon (e.g., the default Pantheon environment URL, and the custom domain), and the site is a multisite with an additional domain (e.g., a blog site), you would specify all 3 domains for each environment like this:\n"
      echo -e "  --live-domain=\033[36mlive-example.pantheonsite.io\033[0m,\033[36mexample.com\033[0m,\033[36mblog.example.com\033[0m"
      echo -e "  --test-domain=\033[36mtest-example.pantheonsite.io\033[0m,\033[36mstaging.example.com\033[0m,\033[36mstaging.blog.example.com\033[0m"
      echo -e "  --dev-domain=\033[36mdev-example.pantheonsite.io\033[0m,\033[36mdev.example.com\033[0m,\033[36mdev.blog.example.com\033[0m"
      echo -e "  --ddev-domain=\033[36mexample.ddev.site\033[0m,\033[36mexample.ddev.site\033[0m,\033[36mblog.example.ddev.site\033[0m\n"
      exit 0
      ;;

    -*|--*)
      echo -e "\033[31mUnknown option $1\033[0m"
      exit 0
      ;;

    *)
      shift # past argument
      ;;
  esac
done

if [ -z "$DDEV_PROJECT" ]; then
  echo -e "\033[31mNo DDEV project detected. Make sure you are executing this command within the directory of a DDEV project, in which the application is running.\033[0m"
  exit 0
fi

if [[ "$ENV" == "dev" ]]; then
  if [ ${#DEV_DOMAINS[@]} -eq 0 ]; then
    echo -e "\033[31mPlease provide a development domain using the --dev-domain flag.\033[0m"
    exit 0
  fi

  SOURCE_ENV_DOMAINS=("${DEV_DOMAINS[@]}")
elif [[ "$ENV" == "test" ]]; then
  if [ ${#TEST_DOMAINS[@]} -eq 0 ]; then
    echo -e "\033[31mPlease provide a staging domain using the --test-domain flag.\033[0m"
    exit 0
  fi

  SOURCE_ENV_DOMAINS=("${TEST_DOMAINS[@]}")
elif [[ "$ENV" == "live" ]]; then
  if [ ${#LIVE_DOMAINS[@]} -eq 0 ]; then
    echo -e "\033[31mPlease provide a live domain using the --live-domain flag.\033[0m"
    exit 0
  fi
  
  SOURCE_ENV_DOMAINS=("${LIVE_DOMAINS[@]}")
else
  echo -e "\033[31mInvalid environment specified. Use 'dev', 'test', or 'live'.\033[0m"
  exit 0
fi

echo -e "Syncing the database and files from the \033[36m$SITE_NAME $ENV\033[0m environment...\n"
echo -e "Creating a database backup... \033[36m(keeping for 1 day)\033[0m"

# Show a spinner while running a command
run_with_spinner() {
  local tmpfile=$(mktemp)
  ("$@") >"$tmpfile" 2>&1 &
  local cmd_pid=$!
  local delay=0.1
  local spinstr='|/-\'
  tput civis 2>/dev/null

  while kill -0 $cmd_pid 2>/dev/null; do
    for i in $(seq 0 3); do
      printf "\r[%c] " "${spinstr:$i:1}"
      sleep $delay
    done
  done

  printf "\r    \r"
  tput cnorm 2>/dev/null
  wait $cmd_pid
  local exit_code=$?
  OUTPUT=$(cat "$tmpfile")
  rm -f "$tmpfile"

  return $exit_code
}

# Create a backup of the remote environment's database
run_with_spinner terminus backup:create --element=database --keep-for=1 -- $SITE_SLUG.$ENV

if [[ "$OUTPUT" == *"Created a backup"* ]]; then
  echo -e "\033[32mBackup database created\033[0m\n"
else
  echo "$OUTPUT"
  exit 0
fi

TEMP_DIR="$DDEV_APPROOT/.ddev/.tmp"

# Create a temporary directory if it doesn't exist
if [ ! -d "$TEMP_DIR" ]; then
  mkdir -p "$TEMP_DIR"
fi

BACKUP_DATE=$(date -u +"%Y-%m-%dT%H-%M-%S")
DATABASE_FILEPATH="$TEMP_DIR/$SITE_SLUG-$ENV-$BACKUP_DATE-UTC-database.sql.gz"

echo -e "Downloading the backup database..."

run_with_spinner terminus backup:get --element=database --to=$DATABASE_FILEPATH -- $SITE_SLUG.$ENV

if [ -e "$DATABASE_FILEPATH" ]; then
  echo -e "\033[32mBackup database downloaded\033[0m\n"
else
  echo "$OUTPUT"
  exit 0
fi

echo "Importing the database..."

run_with_spinner ddev import-db --file="$DATABASE_FILEPATH"

if [[ "$OUTPUT" == *"Successfully imported"* ]]; then
  echo -e "\033[32mThe database was successfully imported\033[0m"
else
  echo "$OUTPUT"
  exit 0
fi

# Remove the temporary folder and its contents
rm -rf "$TEMP_DIR"

if [[ "${#SOURCE_ENV_DOMAINS[@]}" -eq 1 ]]; then
  echo -e "\nReplacing URLs in the database from \033[36m$SOURCE_ENV_DOMAINS\033[0m to \033[36m$DDEV_DOMAINS\033[0m..."
else
  echo -e "\nReplacing URLs in the database from:"
  
  for ((i=0; i<${#SOURCE_ENV_DOMAINS[@]}; i++)); do
    echo -e "  - \033[36m${SOURCE_ENV_DOMAINS[$i]}\033[0m to \033[36m${DDEV_DOMAINS[$i]}\033[0m"
  done
fi

REPLACEMENT_COMMANDS=()

for ((i=0; i<${#SOURCE_ENV_DOMAINS[@]}; i++)); do
  REPLACEMENT_COMMANDS+=("ddev wp search-replace '(^|[^@])${SOURCE_ENV_DOMAINS[$i]}' '\1${DDEV_DOMAINS[$i]}' --regex --regex-flags=i --all-tables-with-prefix --skip-columns=guid --skip-plugins --skip-themes")
done

COMMAND_SEPARATOR=' && '
REPLACEMENT_COMMANDS=$(printf "%s$COMMAND_SEPARATOR" "${REPLACEMENT_COMMANDS[@]}")
REPLACEMENT_COMMANDS=${REPLACEMENT_COMMANDS%$COMMAND_SEPARATOR} # Remove the trailing separator

if [ "$VERBOSE" -eq 1 ]; then
  echo -e "\nRunning the following commands to replace URLs in the database:\n"
  echo -e "\033[36m$REPLACEMENT_COMMANDS\033[0m\n"
fi

run_with_spinner bash -c "$REPLACEMENT_COMMANDS"

REPLACEMENTS=0

for n in $(echo "$OUTPUT" | grep -oE 'Success: Made [0-9]+' | grep -oE '[0-9]+'); do
  REPLACEMENTS=$((REPLACEMENTS + n))
done

if [[ "$REPLACEMENTS" -eq 1 ]]; then
  echo -e "\033[32m1 replacement made\033[0m"
else
  echo -e "\033[32m$REPLACEMENTS replacements made\033[0m"
fi

echo -e "\nFlushing the WordPress cache..."

# Flush the WordPress cache to ensure all changes are applied
# This command uses the DDEV WP CLI to flush the cache for the specified URL
# The --skip-plugins and --skip-themes flags are used to avoid running any plugins
# or themes that might interfere with the cache flush process
run_with_spinner ddev wp cache flush --url=${DDEV_DOMAINS[0]} --skip-plugins --skip-themes

if [[ "$OUTPUT" == *"Success:"* ]]; then
  echo -e "\033[32mThe cache was successfully flushed\033[0m"
else
  echo "$OUTPUT"
fi

echo -e "\nChecking for files to sync..."

FILES_SOURCE="$ENV.$SITE_ID@appserver.$ENV.$SITE_ID.drush.in:files/"
FILES_DESTINATION="$DDEV_APPROOT/wp-content/uploads/"

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
run_with_spinner rsync -rLv4n --stats --ignore-existing --copy-unsafe-links --size-only -e 'ssh -p 2222' "$FILES_SOURCE" "$FILES_DESTINATION"

TOTAL_FILES_TO_SYNC=$(echo "$OUTPUT" | gawk '/^Transfer starting:/{flag=1;next}/sent [0-9]+ bytes/{flag=0}flag' | grep -v '^[[:space:]]*$' | grep -v '/$' | grep -v 'Skip existing' | wc -l | xargs)

SYNC_COMPLETE_NEW_LINE="\n"

if [ "$TOTAL_FILES_TO_SYNC" -gt 0 ]; then
  echo -e "Syncing \033[36m$TOTAL_FILES_TO_SYNC\033[0m files..."

  SYNCED=0
  TOTAL_MEGABYTES=0
  OUTPUT_MEGABYTES=0
  PROGRESS_BAR_WIDTH=40
  PERCENT_COMPLETE=0
  SYNC_COMPLETE_NEW_LINE="\n\n"

  # Run rsync and parse output
  rsync -rLv4z --progress --ignore-existing --copy-unsafe-links --size-only -e 'ssh -p 2222' "$FILES_SOURCE" "$FILES_DESTINATION" 2>&1 | \
  while IFS= read -r line; do
    if [[ "$line" == *"%"* ]]; then
      BYTES=$(echo "$line" | awk '{print $1}' | xargs)
      MEGABYTES=$(awk "BEGIN {printf \"%.2f\", $BYTES/1000000}")
      OUTPUT_MEGABYTES=$(awk "BEGIN {printf \"%.2f\", $TOTAL_MEGABYTES + $MEGABYTES}")

      # Detect lines that indicate a file has finished transferring
      if [[ "$line" == *"100%"* ]]; then
        ((SYNCED++))

        TOTAL_MEGABYTES=$OUTPUT_MEGABYTES
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
      fi

      printf "\r%s%s %d%% %.2fMB (%d/%d)" "$COMPLETE_BARS" "$INCOMPLETE_BARS" "$PERCENT_COMPLETE" "$OUTPUT_MEGABYTES" "$SYNCED" "$TOTAL_FILES_TO_SYNC"
    fi
  done
else
  echo -e "\033[32mYou're all caught up!\033[0m"
fi

echo -e "$SYNC_COMPLETE_NEW_LINE\e[1m\033[32mSync complete\033[0m\033[0m"
