#!/usr/bin/env bash

# Syncs the database and files from a specified Pantheon environment.

# Command Example: pantheon-sync --site-name="Example Site" --site-slug=example --site-id=7acab2d5-c574-4c73-9baf-d9ec1e17abc3 --env=live --live-source-domains=example.com --live-replacement-domains=example.ddev.site

# Flags:
#   --site-name                 The name of the site on the Pantheon dashboard (e.g., "Example Site").
#   --site-slug                 The slug of the site, which is found in the dev, test, and live Pantheon environment URL.
#   --site-id                   The unique ID of the site (e.g., "7acab2d5-c574-4c73-9baf-d9ec1e17abc3").
#   --env                       The environment to pull from ("dev", "test", "live", or the multidev environment slug).
#   --live-source-domains       Source domains for the live environment (optional if --site-slug is set).
#   --live-replacement-domains  Replacement domains for the live environment.
#   --test-source-domains       Source domains for the test environment (optional, falls back to live).
#   --test-replacement-domains  Replacement domains for the test environment (optional, falls back to live).
#   --dev-source-domains        Source domains for the dev environment (optional, falls back to live).
#   --dev-replacement-domains   Replacement domains for the dev environment (optional, falls back to live).
#   --other-source-domains      Source domains for other environments, e.g. multidev (optional, falls back to live).
#   --other-replacement-domains Replacement domains for other environments (optional, falls back to live).
#   --ddev-project-root         The root directory of the DDEV project.
#   --sync                      What to sync: 'all' (default), 'db', or 'files'.
#   --verbose                   Enables verbose output for debugging purposes.
#   --version                   Shows the version of the script.
#   --update                    Updates the "pantheon-sync" homebrew formula.
#   --help                      Shows command usage and available flags.

# Note for Domains

# 1. The Pantheon environment URL ({env}-{site-slug}.pantheonsite.io) is automatically added to
#    the selected environment's source domains and paired with the primary DDEV URL as its replacement,
#    unless that URL is already present.

# 2. Use --live-source-domains for the live environment's custom domains. Optionally use
#    --test-source-domains, --dev-source-domains, and --other-source-domains for environment-specific
#    domains. If env-specific domains are not set, the live domains are used as a fallback.

#    Example (different domains per environment):

#    --live-source-domains=blog.example.com,example.com
#    --live-replacement-domains=blog.example.ddev.site,example.ddev.site
#    --test-source-domains=blog.staging.example.com,staging.example.com
#    --test-replacement-domains=blog.example.ddev.site,example.ddev.site

# 3. The order of domains in source flags determines the mapping to replacement flags. The
#    script will replace each source domain with the corresponding replacement domain.

# Version of the script used for release tracking and the Homebrew formula.
VERSION="0.6.6"

# Domain arrays used to map source and replacement hostnames for each environment.
LIVE_SOURCE_DOMAINS=()
LIVE_REPLACEMENT_DOMAINS=()
TEST_SOURCE_DOMAINS=()
TEST_REPLACEMENT_DOMAINS=()
DEV_SOURCE_DOMAINS=()
DEV_REPLACEMENT_DOMAINS=()
OTHER_SOURCE_DOMAINS=()
OTHER_REPLACEMENT_DOMAINS=()
SOURCE_DOMAINS=()
REPLACEMENT_DOMAINS=()

# Runtime configuration flags.
VERBOSE=0
SYNC="all"

# Parse a comma-separated list of domains into an array and trim whitespace.
extract_domains() {
  local input="$1"
  local -n output_array=$2
  IFS=',' read -ra DOMAINS <<< "$input"
  for domain in "${DOMAINS[@]}"; do
    trimmed_domain="$(echo "$domain" | xargs)"
    output_array+=("$trimmed_domain")
  done
}

# Process CLI arguments and set runtime configuration.
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

    --live-source-domains=*)
      extract_domains "${1#*=}" LIVE_SOURCE_DOMAINS
      shift
      ;;

    --live-replacement-domains=*)
      extract_domains "${1#*=}" LIVE_REPLACEMENT_DOMAINS
      shift
      ;;

    --test-source-domains=*)
      extract_domains "${1#*=}" TEST_SOURCE_DOMAINS
      shift
      ;;

    --test-replacement-domains=*)
      extract_domains "${1#*=}" TEST_REPLACEMENT_DOMAINS
      shift
      ;;

    --dev-source-domains=*)
      extract_domains "${1#*=}" DEV_SOURCE_DOMAINS
      shift
      ;;

    --dev-replacement-domains=*)
      extract_domains "${1#*=}" DEV_REPLACEMENT_DOMAINS
      shift
      ;;

    --other-source-domains=*)
      extract_domains "${1#*=}" OTHER_SOURCE_DOMAINS
      shift
      ;;

    --other-replacement-domains=*)
      extract_domains "${1#*=}" OTHER_REPLACEMENT_DOMAINS
      shift
      ;;

    --ddev-project-root=*)
      DDEV_PROJECT_ROOT="${1#*=}"
      shift
      ;;

    --sync=*)
      SYNC="${1#*=}"
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
      # Refresh the Homebrew formula to pull the latest published version.
      brew uninstall pantheon-sync wpengine-sync
      brew untap padillaco/homebrew-formulas
      brew tap padillaco/homebrew-formulas
      brew install pantheon-sync wpengine-sync
      exit 0
      ;;

    --version)
      echo "pantheon-sync version $VERSION"
      exit 0
      ;;

    --help)
      echo -e "Usage: pantheon-sync [flags]\n"
      echo -e "\033[1mFlags:\033[0m"
      echo -e "  --site-name                 The name of the site on the Pantheon dashboard (e.g., \"Example Site\")."
      echo -e "  --site-slug                 The slug of the site, which is found in the dev, test, and live Pantheon environment URL."
      echo -e "  --site-id                   The unique ID of the site (e.g., \"7acab2d5-c574-4c73-9baf-d9ec1e17abc3\")."
      echo -e "  --env                       The environment to pull from (\"dev\", \"test\", \"live\", or the multidev environment slug)."
      echo -e "  --live-source-domains       Source domains for the live environment (optional if --site-slug is set)."
      echo -e "  --live-replacement-domains  Replacement domains for the live environment."
      echo -e "  --test-source-domains       Source domains for the test environment (optional, falls back to live)."
      echo -e "  --test-replacement-domains  Replacement domains for the test environment (optional, falls back to live)."
      echo -e "  --dev-source-domains        Source domains for the dev environment (optional, falls back to live)."
      echo -e "  --dev-replacement-domains   Replacement domains for the dev environment (optional, falls back to live)."
      echo -e "  --other-source-domains      Source domains for other environments, e.g. multidev (optional, falls back to live)."
      echo -e "  --other-replacement-domains Replacement domains for other environments (optional, falls back to live)."
      echo -e "  --ddev-project-root         The root directory of the DDEV project."
      echo -e "  --sync                      What to sync: 'all' (default), 'db', or 'files'."
      echo -e "  --verbose                   Enables verbose output for debugging purposes."
      echo -e "  --version                   Shows the version of the script."
      echo -e "  --update                    Updates the \"pantheon-sync\" homebrew formula."
      echo -e "  --help                      Shows command usage and available flags.\n"
      echo -e "\033[1m\033[4m\033[33mNote for Domains\033[0m\n"
      echo -e "\033[1m\033[33m1.\033[0m The Pantheon environment URL (\033[36m{env}-{site-slug}.pantheonsite.io\033[0m) is automatically added to"
      echo -e "   the selected environment's source domains and paired with the primary DDEV URL, unless already present.\n"
      echo -e "\033[1m\033[33m2.\033[0m Use \033[36m--live-source-domains\033[0m for live custom domains. Optionally use \033[36m--test-source-domains\033[0m,"
      echo -e "   \033[36m--dev-source-domains\033[0m, and \033[36m--other-source-domains\033[0m for environment-specific domains."
      echo -e "   If env-specific domains are not set, the live domains are used as a fallback.\n"
      echo -e "   \033[1mExample (different domains per environment):\033[0m\n"
      echo -e "   --live-source-domains=\033[36mblog.example.com\033[0m,\033[36mexample.com\033[0m"
      echo -e "   --live-replacement-domains=\033[36mblog.example.ddev.site\033[0m,\033[36mexample.ddev.site\033[0m"
      echo -e "   --test-source-domains=\033[36mblog.staging.example.com\033[0m,\033[36mstaging.example.com\033[0m"
      echo -e "   --test-replacement-domains=\033[36mblog.example.ddev.site\033[0m,\033[36mexample.ddev.site\033[0m\n"
      echo -e "\033[1m\033[33m3.\033[0m The order of domains in source flags determines the mapping to replacement flags. The"
      echo -e "   script will replace each source domain with the corresponding replacement domain.\n"
      exit 0
      ;;

    -*|--*)
      echo -e "\033[31mUnknown option $1\033[0m"
      exit 1
      ;;

    *)
      shift # past argument
      ;;
  esac
done

# Ensure we are running from a DDEV project directory so the local WordPress environment is available.
if [ -z "$DDEV_PROJECT" ]; then
  if [ -n "$DDEV_PROJECT_ROOT" ] && [ -d "$DDEV_PROJECT_ROOT" ]; then
    cd "$DDEV_PROJECT_ROOT"
  fi

  if [ -z "$DDEV_PROJECT" ]; then
    echo -e "\033[31mNo DDEV project detected. Make sure you are executing this command within the directory of a DDEV project, in which the application is running.\033[0m"
    exit 1
  fi
fi

# Require an environment; named Pantheon environments and multidevs share the same sync path.
if [[ -z "$ENV" ]]; then
  echo -e "\033[31mPlease specify an environment to sync from using the --env flag ('dev', 'test', 'live', or the multidev environment slug).\033[0m"
  exit 1
fi

# Select the environment-specific domain pairs, with a fallback to the live configuration when needed.
if [[ "$ENV" == "test" ]] && [ ${#TEST_SOURCE_DOMAINS[@]} -gt 0 ]; then
  SOURCE_DOMAINS=("${TEST_SOURCE_DOMAINS[@]}")
  REPLACEMENT_DOMAINS=("${TEST_REPLACEMENT_DOMAINS[@]}")
elif [[ "$ENV" == "dev" ]] && [ ${#DEV_SOURCE_DOMAINS[@]} -gt 0 ]; then
  SOURCE_DOMAINS=("${DEV_SOURCE_DOMAINS[@]}")
  REPLACEMENT_DOMAINS=("${DEV_REPLACEMENT_DOMAINS[@]}")
elif [[ "$ENV" != "live" && "$ENV" != "test" && "$ENV" != "dev" ]] && [ ${#OTHER_SOURCE_DOMAINS[@]} -gt 0 ]; then
  SOURCE_DOMAINS=("${OTHER_SOURCE_DOMAINS[@]}")
  REPLACEMENT_DOMAINS=("${OTHER_REPLACEMENT_DOMAINS[@]}")
else
  SOURCE_DOMAINS=("${LIVE_SOURCE_DOMAINS[@]}")
  REPLACEMENT_DOMAINS=("${LIVE_REPLACEMENT_DOMAINS[@]}")
fi

# Add the Pantheon environment URL when a site slug is available, pairing it with the primary DDEV URL.
if [ -n "$SITE_SLUG" ]; then
  GENERATED_ENV_DOMAIN="${ENV}-${SITE_SLUG}.pantheonsite.io"
  DOMAIN_ALREADY_SET=0
  for domain in "${SOURCE_DOMAINS[@]}"; do
    if [[ "$domain" == "$GENERATED_ENV_DOMAIN" ]]; then
      DOMAIN_ALREADY_SET=1
      break
    fi
  done

  if [ "$DOMAIN_ALREADY_SET" -eq 0 ]; then
    SOURCE_DOMAINS+=("$GENERATED_ENV_DOMAIN")
    REPLACEMENT_DOMAINS+=("${DDEV_PRIMARY_URL#*://}")
  fi
fi

if [ ${#SOURCE_DOMAINS[@]} -eq 0 ]; then
  echo -e "\033[33mNo custom domains were provided for the $ENV environment. Only the default environment URL will be replaced.\033[0m"
fi

# Validate the requested sync scope before contacting Pantheon or DDEV.
if [[ "$SYNC" != "all" && "$SYNC" != "db" && "$SYNC" != "files" ]]; then
  echo -e "\033[31mInvalid --sync value. Use 'all', 'db', or 'files'.\033[0m"
  exit 1
fi

# Run a long-lived command with a simple spinner so the user sees activity while work is happening.
run_with_spinner() {
  local tmpfile=$(mktemp)
  ("$@") >"$tmpfile" 2>&1 </dev/null &
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

if [[ "$SYNC" == "db" ]]; then
  echo -e "Syncing the database from the \033[36m$SITE_NAME $ENV\033[0m environment...\n"
elif [[ "$SYNC" == "files" ]]; then
  echo -e "Syncing the files from the \033[36m$SITE_NAME $ENV\033[0m environment...\n"
else
  echo -e "Syncing the database and files from the \033[36m$SITE_NAME $ENV\033[0m environment...\n"
fi

if [[ "$SYNC" != "files" ]]; then

# Create a remote database backup before downloading it locally.
echo -e "Creating a database backup... \033[36m(keeping for 1 day)\033[0m"

# Create a backup of the remote environment's database
run_with_spinner terminus backup:create --element=database --keep-for=1 -- $SITE_SLUG.$ENV

if [[ "$OUTPUT" == *"Created a backup"* ]]; then
  echo -e "\033[32mBackup database created\033[0m\n"
else
  echo "$OUTPUT"
  exit 1
fi

# Store the downloaded database under DDEV's temporary directory until import completes.
TEMP_DIR="$DDEV_APPROOT/.ddev/.tmp"

# Create the temporary directory if it doesn't exist.
if [ ! -d "$TEMP_DIR" ]; then
  mkdir -p "$TEMP_DIR"
fi

BACKUP_DATE=$(date -u +"%Y-%m-%dT%H-%M-%S")
DATABASE_FILEPATH="$TEMP_DIR/$SITE_SLUG-$ENV-$BACKUP_DATE-UTC-database.sql.gz"

echo -e "Downloading the backup database..."

# Download the Pantheon backup to the temporary local path.
run_with_spinner terminus backup:get --element=database --to=$DATABASE_FILEPATH -- $SITE_SLUG.$ENV

if [ -e "$DATABASE_FILEPATH" ]; then
  echo -e "\033[32mBackup database downloaded\033[0m\n"
else
  echo "$OUTPUT"
  exit 1
fi

echo "Importing the database..."

# Import the downloaded database into the current DDEV project.
run_with_spinner ddev import-db --file="$DATABASE_FILEPATH"

if [[ "$OUTPUT" == *"Successfully imported"* ]]; then
  echo -e "\033[32mThe database was successfully imported\033[0m"
else
  echo "$OUTPUT"
  exit 1
fi

# Remove the temporary folder and its contents
rm -rf "$TEMP_DIR"

if [[ "${#SOURCE_DOMAINS[@]}" -eq 1 ]]; then
  echo -e "\nReplacing domains in the database from \033[36m$SOURCE_DOMAINS\033[0m to \033[36m$REPLACEMENT_DOMAINS\033[0m..."
else
  echo -e "\nReplacing domains in the database from:"
  
  for ((i=0; i<${#SOURCE_DOMAINS[@]}; i++)); do
    echo -e "  - \033[36m${SOURCE_DOMAINS[$i]}\033[0m to \033[36m${REPLACEMENT_DOMAINS[$i]}\033[0m"
  done
fi

# Replace nested domains before top-level ones so the deepest hostnames are updated before broader matches.
declare -a SORTED_PAIRS
for ((i=0; i<${#SOURCE_DOMAINS[@]}; i++)); do
  dot_count=$(($(echo "${SOURCE_DOMAINS[$i]}" | tr -cd '.' | wc -c)))
  SORTED_PAIRS+=("$dot_count|$i")
done
IFS=$'\n' SORTED_PAIRS=($(sort -rn <<<"${SORTED_PAIRS[*]}"))
unset IFS

declare -a SORTED_SOURCE_DOMAINS
declare -a SORTED_REPLACEMENT_DOMAINS
for pair in "${SORTED_PAIRS[@]}"; do
  idx="${pair##*|}"
  SORTED_SOURCE_DOMAINS+=("${SOURCE_DOMAINS[$idx]}")
  SORTED_REPLACEMENT_DOMAINS+=("${REPLACEMENT_DOMAINS[$idx]}")
done

SOURCE_DOMAINS=("${SORTED_SOURCE_DOMAINS[@]}")
REPLACEMENT_DOMAINS=("${SORTED_REPLACEMENT_DOMAINS[@]}")

if [ "$VERBOSE" -eq 1 ]; then
  echo -e "\nRunning the following commands to replace domains in the database:\n"
  for ((i=0; i<${#SOURCE_DOMAINS[@]}; i++)); do
    echo -e "  \033[36mddev wp search-replace '${SOURCE_DOMAINS[$i]}' '${REPLACEMENT_DOMAINS[$i]}' --all-tables-with-prefix --skip-columns=guid --skip-plugins --skip-themes 2>/dev/null\033[0m"
  done
  echo ""
fi

TOTAL_DOMAIN_COUNT=${#SOURCE_DOMAINS[@]}
COMPLETED_DOMAIN_COUNT=0
REPLACEMENTS=0
SPINSTR='|/-\'
tput civis 2>/dev/null

# Apply each domain replacement to the local WordPress database using WP-CLI.
for ((i=0; i<${#SOURCE_DOMAINS[@]}; i++)); do
  DOMAIN_CMD="ddev wp search-replace '${SOURCE_DOMAINS[$i]}' '${REPLACEMENT_DOMAINS[$i]}' --all-tables-with-prefix --skip-columns=guid --skip-plugins --skip-themes 2>/dev/null"
  DOMAIN_TMPFILE=$(mktemp)
  bash -c "$DOMAIN_CMD" >"$DOMAIN_TMPFILE" 2>&1 </dev/null &
  DOMAIN_CMD_PID=$!

  while kill -0 $DOMAIN_CMD_PID 2>/dev/null; do
    for j in $(seq 0 3); do
      printf "\r%d of %d domains replaced [%c]  " "$COMPLETED_DOMAIN_COUNT" "$TOTAL_DOMAIN_COUNT" "${SPINSTR:$j:1}"
      sleep 0.1
    done
  done

  wait $DOMAIN_CMD_PID
  DOMAIN_OUTPUT=$(cat "$DOMAIN_TMPFILE")
  rm -f "$DOMAIN_TMPFILE"

  COMPLETED_DOMAIN_COUNT=$((COMPLETED_DOMAIN_COUNT + 1))

  for n in $(echo "$DOMAIN_OUTPUT" | grep -oE 'Success: Made [0-9]+' | grep -oE '[0-9]+'); do
    REPLACEMENTS=$((REPLACEMENTS + n))
  done
done

printf "\r%-50s\r" ""
tput cnorm 2>/dev/null

if [[ "$REPLACEMENTS" -eq 1 ]]; then
  echo -e "\033[32m1 total replacement made\033[0m"
else
  echo -e "\033[32m$REPLACEMENTS total replacements made\033[0m"
fi

echo -e "\nRestoring email addresses to original domains..."

TOTAL_EMAIL_DOMAIN_COUNT=${#SOURCE_DOMAINS[@]}
COMPLETED_EMAIL_DOMAIN_COUNT=0
EMAIL_RESTORATIONS=0
tput civis 2>/dev/null

if [ "$VERBOSE" -eq 1 ]; then
  echo -e "\nRunning the following commands to restore email domains in the database:\n"
  for ((i=0; i<${#SOURCE_DOMAINS[@]}; i++)); do
    echo -e "  \033[36mddev wp search-replace '@${REPLACEMENT_DOMAINS[$i]}' '@${SOURCE_DOMAINS[$i]}' --all-tables-with-prefix --skip-columns=guid --skip-plugins --skip-themes 2>/dev/null\033[0m"
  done
  echo ""
fi

# Restore email addresses that use the local replacement domains back to their original domains.
for ((i=0; i<${#SOURCE_DOMAINS[@]}; i++)); do
  EMAIL_CMD="ddev wp search-replace '@${REPLACEMENT_DOMAINS[$i]}' '@${SOURCE_DOMAINS[$i]}' --all-tables-with-prefix --skip-columns=guid --skip-plugins --skip-themes 2>/dev/null"
  EMAIL_TMPFILE=$(mktemp)
  bash -c "$EMAIL_CMD" >"$EMAIL_TMPFILE" 2>&1 </dev/null &
  EMAIL_CMD_PID=$!

  while kill -0 $EMAIL_CMD_PID 2>/dev/null; do
    for j in $(seq 0 3); do
      printf "\r%d of %d email domains restored [%c]  " "$COMPLETED_EMAIL_DOMAIN_COUNT" "$TOTAL_EMAIL_DOMAIN_COUNT" "${SPINSTR:$j:1}"
      sleep 0.1
    done
  done

  wait $EMAIL_CMD_PID
  EMAIL_OUTPUT=$(cat "$EMAIL_TMPFILE")
  rm -f "$EMAIL_TMPFILE"

  COMPLETED_EMAIL_DOMAIN_COUNT=$((COMPLETED_EMAIL_DOMAIN_COUNT + 1))

  for n in $(echo "$EMAIL_OUTPUT" | grep -oE 'Success: Made [0-9]+' | grep -oE '[0-9]+'); do
    EMAIL_RESTORATIONS=$((EMAIL_RESTORATIONS + n))
  done
done

printf "\r%-50s\r" ""
tput cnorm 2>/dev/null

if [[ "$EMAIL_RESTORATIONS" -eq 1 ]]; then
  echo -e "\033[32m1 email domain restored\033[0m"
else
  echo -e "\033[32m$EMAIL_RESTORATIONS email domains restored\033[0m"
fi

echo -e "\nFlushing the WordPress cache..."

# Clear the local site cache after domain replacements so the new URLs are immediately reflected.
# The custom flags avoid running WordPress plugins or themes during the cache flush.
run_with_spinner ddev wp cache flush --url=${REPLACEMENT_DOMAINS[0]} --skip-plugins --skip-themes

if [[ "$OUTPUT" == *"Success:"* ]]; then
  echo -e "\033[32mThe cache was successfully flushed\033[0m"
else
  echo "$OUTPUT"
fi

fi # end database sync

SYNC_COMPLETE_NEW_LINE="\n"

if [[ "$SYNC" != "db" ]]; then

# Pull media uploads from the selected Pantheon environment into the local DDEV project.
[[ "$SYNC" != "files" ]] && echo ""
echo "Checking for files to sync..."

FILES_SOURCE="$ENV.$SITE_ID@appserver.$ENV.$SITE_ID.drush.in:files/"
FILES_DESTINATION="$DDEV_APPROOT/wp-content/uploads/"

# Sync the files from the remote environment to the local uploads folder.
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

# Count total files to sync (excluding files already present locally) before transferring them.
run_with_spinner rsync -rLv4n --stats --ignore-existing --copy-unsafe-links --size-only -e 'ssh -p 2222' "$FILES_SOURCE" "$FILES_DESTINATION"

TOTAL_FILES_TO_SYNC=$(echo "$OUTPUT" | gawk '/^Transfer starting:/{flag=1;next}/sent [0-9]+ bytes/{flag=0}flag' | grep -v '^[[:space:]]*$' | grep -v '/$' | grep -v 'Skip existing' | wc -l | xargs)

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

fi # end files sync

echo -e "$SYNC_COMPLETE_NEW_LINE\e[1m\033[32mSync complete\033[0m\033[0m"
