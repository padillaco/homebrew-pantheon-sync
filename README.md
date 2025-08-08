# Pantheon Sync

Syncs the database and files from a specified Pantheon environment.

**Command Example:**
```sh
pantheon-sync --site-name=MySite --site-slug=my-site --site-id=7acab2d5-c574-4c73-9baf-d9ec1e17abc3 --env=live --live-domain=mysite.com --test-domain=staging.mysite.com --dev-domain=dev.mysite.com --ddev-domain=my-site.ddev.site
```

## Flags

| Flag                | Description                                                                                           |
|---------------------|-------------------------------------------------------------------------------------------------------|
| `--site-name`       | The name of the site on the Pantheon dashboard (e.g., "My Site").                                     |
| `--site-slug`       | The slug of the site, which is found in the Pantheon environment URL (e.g., "my-site").               |
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

1. To specify multiple domains for an environment, provide a comma-separated list of domains within a single flag. For example:

    ```sh
    --dev-domain=dev1.example.com,dev2.example.com
    ```

2. Each environment domain flag must have the same number of domains, and in the same order, as the other environment domain flags, to ensure that the wp search-replace command can replace each source domain with the correct DDEV domain.

    For example, if you have two different domains for each environment on Pantheon (e.g., the default Pantheon environment URL, and the custom domain), and the site is a multisite with an additional domain (e.g., a blog site), you would specify all 3 domains for each environment like this:

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