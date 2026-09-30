# Pantheon Sync (Bash Command)

Syncs the database and files from a specified Pantheon environment.

- [Installation and Updates](#installation-and-updates)
- [Command Example](#command-example)
- [Command Flags](#command-flags)
- [Note for Domains](#note-for-domains)
- [DDEV Command Setup](#ddev-command-setup)
- [Contributing](#contributing)

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
$ pantheon-sync --site-name="Example Site" --site-slug=example --site-id=7acab2d5-c574-4c73-9baf-d9ec1e17abc3 --env=live --live-source-domains=example.com --live-replacement-domains=example.ddev.site
```

## Command Flags

| Flag                  | Description                                                                                           |
|-----------------------|-------------------------------------------------------------------------------------------------------|
| `--site-name`         | The name of the site on the Pantheon dashboard (e.g., "Example Site").                                |
| `--site-slug`         | The slug of the site, which is found in the dev, test, and live Pantheon environment URL.             |
| `--site-id`           | The unique ID of the site (e.g., "7acab2d5-c574-4c73-9baf-d9ec1e17abc3").                             |
| `--env`               | The environment to pull from ("dev", "test", "live", or the multidev environment slug).               |
| `--live-source-domains` | Custom domains to search/replace for the live environment. The Pantheon environment URL (`{env}-{site-slug}.pantheonsite.io`) is automatically added. |
| `--live-replacement-domains` | Replacement domains for the live environment (the local DDEV domains). Must match the order of `--live-source-domains`. |
| `--test-source-domains` | Custom domains for the test environment (optional, falls back to live domains). |
| `--test-replacement-domains` | Replacement domains for the test environment. Must match the order of `--test-source-domains`. |
| `--dev-source-domains` | Custom domains for the dev environment (optional, falls back to live domains). |
| `--dev-replacement-domains` | Replacement domains for the dev environment. Must match the order of `--dev-source-domains`. |
| `--other-source-domains` | Custom domains for other environments, e.g. multidev (optional, falls back to live domains). |
| `--other-replacement-domains` | Replacement domains for other environments. Must match the order of `--other-source-domains`. |
| `--ddev-project-root` | The root directory of the DDEV project.                                                               |
| `--sync`              | What to sync: `all` (default), `db`, or `files`.                                                      |
| `--verbose`           | Enables verbose output for debugging purposes.                                                        |
| `--version`           | Shows the version of the script.                                                                      |
| `--update`            | Updates the "pantheon-sync" homebrew formula.                                                         |
| `--help`              | Shows command usage and available flags.                                                              |

## Note for Domains

1. The Pantheon environment URL (`{env}-{site-slug}.pantheonsite.io`) is automatically added to the selected environment's source domains and paired with the primary DDEV URL as its replacement, unless that URL is already present.

2. Use `--live-source-domains` for the live environment's custom domains. Optionally use `--test-source-domains`, `--dev-source-domains`, and `--other-source-domains` for environment-specific domains. If env-specific domains are not set, the live domains are used as a fallback.

   **Example (different domains per environment):**

    ```sh
    --live-source-domains=blog.example.com,example.com
    --live-replacement-domains=blog.example.ddev.site,example.ddev.site
    --test-source-domains=blog.staging.example.com,staging.example.com
    --test-replacement-domains=blog.example.ddev.site,example.ddev.site
    ```

3. The order of domains in source flags determines the mapping to replacement flags. The script will replace each source domain found in the database with the corresponding replacement domain.

## DDEV Command Setup

1. Copy the [template.sh](template.sh) file to `.ddev/commands/host/pantheon-sync.sh`.
2. Set the website configuration values in the `pantheon-sync` command call within the file.
3. Run `ddev sync` to sync the database and files from the **live** site, or use any of the following options:

| Command | Description |
|---------|-------------|
| `ddev sync` | Sync the database and files from the live environment |
| `ddev sync --env=test` | Sync from the test/staging environment |
| `ddev sync --db` | Sync the database only |
| `ddev sync --files` | Sync the files only |
| `ddev sync --db --files` | Sync both (same as default) |

**Note:** Running `ddev sync` for the first time will install the `pantheon-sync` command from the [pantheon-sync.rb](https://github.com/padillaco/homebrew-formulas/blob/main/Formula/pantheon-sync.rb) Homebrew formula.

## Contributing

We welcome contributions to improve pantheon-sync! Here's how to contribute:

### Development Workflow

1. **Fork and Clone**
   ```sh
   git clone https://github.com/padillaco/homebrew-pantheon-sync.git
   cd homebrew-pantheon-sync
   ```

2. **Make Your Changes**
   - Edit `pantheon-sync.sh` as needed
   - Test your changes locally
   - Update documentation if necessary

3. **Test Locally**
   ```sh
   # Test the script directly
   bash pantheon-sync.sh --help
   ```

### Versioning and Releases

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backward compatible manner
- **PATCH** version for backward compatible bug fixes

#### Creating a New Release

1. **Update Version Number**
   
   Update the version in `pantheon-sync.sh`:
   ```sh
   VERSION="x.y.z"  # e.g., VERSION="0.5.0"
   ```

2. **Commit Your Changes**
   ```sh
   git add .
   git commit -m "Release v0.5.0: Brief description of changes"
   git push origin main
   ```

3. **Create and Push a Git Tag**
   ```sh
   git tag -a v0.5.0 -m "Release version 0.5.0"
   git push origin v0.5.0
   ```

4. **Create GitHub Release**
   - Go to https://github.com/padillaco/homebrew-pantheon-sync/releases
   - Click "Draft a new release"
   - Select the tag you just created (e.g., `v0.5.0`)
   - Add release notes describing the changes
   - Click "Publish release"

   GitHub will automatically create a tarball at:
   ```
   https://github.com/padillaco/homebrew-pantheon-sync/archive/refs/tags/v0.5.0.tar.gz
   ```

### Updating the Homebrew Formula

After publishing a new release, update the Homebrew formula:

1. **Calculate the SHA256 Hash**
   ```sh
   # Download the tarball and calculate its SHA256
   curl -L https://github.com/padillaco/homebrew-pantheon-sync/archive/refs/tags/v0.5.0.tar.gz -o /tmp/pantheon-sync.tar.gz
   shasum -a 256 /tmp/pantheon-sync.tar.gz
   rm /tmp/pantheon-sync.tar.gz
   ```

2. **Update the Formula**
   
   Edit the formula at https://github.com/padillaco/homebrew-formulas/blob/main/Formula/pantheon-sync.rb:
   
   ```ruby
   class PantheonSync < Formula
     desc "Sync content from Pantheon sites to your local machine"
     homepage "https://github.com/padillaco/homebrew-pantheon-sync"
     url "https://github.com/padillaco/homebrew-pantheon-sync/archive/refs/tags/v0.5.0.tar.gz"
     sha256 "YOUR_NEW_SHA256_HASH_HERE"
     license "MIT"
   ```

3. **Test the Formula**
   ```sh
   brew uninstall pantheon-sync  # Remove old version
   brew install --build-from-source pantheon-sync
   pantheon-sync --version  # Verify new version
   ```

4. **Commit and Push the Formula Update**
   ```sh
   cd /path/to/homebrew-formulas
   git add Formula/pantheon-sync.rb
   git commit -m "Update pantheon-sync to v0.5.0"
   git push origin main
   ```

### Pull Request Guidelines

- Write clear, descriptive commit messages
- Include tests for new features when applicable
- Update documentation for any changed functionality
- Keep changes focused and atomic
- Reference any related issues in your PR description

### Code Style

- Follow existing bash scripting conventions
- Use meaningful variable names
- Comment complex logic
- Keep functions focused and single-purpose
- Use consistent indentation (2 or 4 spaces)

### Getting Help

- Open an issue for bugs or feature requests
- Check existing issues before creating new ones
- Provide detailed information about your environment and the problem
    