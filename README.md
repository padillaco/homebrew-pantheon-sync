# Pantheon Sync (Bash Command)

Syncs the database and files from a specified Pantheon environment.

- [Installation and Updates](#installation-and-updates)
- [Command Example](#command-example)
- [Command Flags](#command-flags)
- [Note for Domain URLs](#note-for-domain-urls)
- [DDEV Command Setup](#ddev-command-setup)

## Installation and Updates

**Requirements:**
- Docker: https://docs.docker.com/engine/install/
- DDEV: https://ddev.com/get-started/
- Homebrew: https://brew.sh/
- Terminus (by Pantheon): https://docs.pantheon.io/terminus/install

**Installation:**

```sh
$ brew tap padillaco/formulas
$ brew install pantheon-sync
```
**Updating to a newer version:**

```sh
$ pantheon-sync --update
```

## Command Example

```sh
$ pantheon-sync --site-name="Example Site" --site-slug=example --site-id=7acab2d5-c574-4c73-9baf-d9ec1e17abc3 --env=live --live-domain=example.com --test-domain=staging.example.com --dev-domain=dev.example.com --ddev-domain=example.ddev.site
```

## Command Flags

| Flag                | Description                                                                                           |
|---------------------|-------------------------------------------------------------------------------------------------------|
| `--site-name`       | The name of the site on the Pantheon dashboard (e.g., "Example Site").                                |
| `--site-slug`       | The slug of the site, which is found in the dev, test, and live Pantheon environment URL.             |
| `--site-id`         | The unique ID of the site (e.g., "7acab2d5-c574-4c73-9baf-d9ec1e17abc3").                             |
| `--env`             | The environment to pull from ("dev", "test", or "live").                                              |
| `--live-domain`     | One or more live domains for the site. See the note below for details.                                |
| `--test-domain`     | One or more test/staging domains for the site. See the note below for details.                        |
| `--dev-domain`      | One or more development domains for the site. See the note below for details.                         |
| `--ddev-domain`     | One or more DDEV domains for the site. See the note below for details.                                |
| `--verbose`         | Enables verbose output for debugging purposes.                                                        |
| `--version`         | Shows the version of the script.                                                                      |
| `--update`          | Updates the "pantheon-sync" homebrew formula.                                                         |
| `--help`            | Shows command usage and available flags.                                                              |

## Note for Domain URLs

1. To specify multiple domains for an environment, provide a comma-separated list of domains for that environment domain flag as shown below.

    **Example:**

    In this example, there are 3 different domains for a multisite on Pantheon (the default Pantheon environment URL, the main custom domain, and a subdomain). Each environment domain flag would contain the following domains as a comma-separated list:

    **Live**

    ```sh
    --live-domain=live-example.pantheonsite.io,example.com,blog.example.com
    ```
    **Test/Staging**
    ```sh
    --test-domain=test-example.pantheonsite.io,staging.example.com,staging.blog.example.com
    ```
    **Development**
    ```sh
    --dev-domain=dev-example.pantheonsite.io,dev.example.com,dev.blog.example.com
    ```
    **DDEV**
    ```sh
    --ddev-domain=example.ddev.site,example.ddev.site,blog.example.ddev.site
    ```

2. The order of domains in each environment domain flag determines the mapping to the DDEV domain. The script will replace each environment domain found in the database with the corresponding DDEV domain.

## DDEV Command Setup

1. Copy the [template.sh](template.sh) file to `.ddev/commands/host/pantheon-sync.sh`.
2. In the **Configuration** section within the file, add the required values for each configuration setting.
3. Run `ddev sync` to sync the database and files from the **live** site, or specify an environment to sync from by running `ddev sync --env=(dev|test|live)`.

**Note:** Running `ddev sync` for the first time will install the `pantheon-sync` command from the set of available Homebrew formulas located at [pantheon-sync.rb](https://github.com/padillaco/homebrew-formulas/blob/main/Formula/pantheon-sync.rb).
    