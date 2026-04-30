# Pantheon Sync (Bash Command)

Syncs the database and files from a specified Pantheon environment.

- [Installation and Updates](#installation-and-updates)
- [Command Example](#command-example)
- [Command Flags](#command-flags)
- [Note for Domain URLs](#note-for-domain-urls)
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
    