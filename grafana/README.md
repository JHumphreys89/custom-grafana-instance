# Grafana Provisioning & Configuration
## Configuring Grafana
Navigate to `grafana/config`. There, you will find a `grafana.ini` and `ldap.toml` file where you can further customize the Grafana instance. Note that this Git repo does not run HTTPS/LDAP, but they can be easily implemented in your environment with minor tweaks.

### `grafana.ini`
- Grafana configurations such as paths are set as environment variables and can be changed in the `Containerfile` within the root directory of the Git repository.
- For HTTPS:
    * Under the `[server]` section, you would want to make the following changes:
    ```ini
    [server]
    # Protocol (http, https, h2, socket)
    protocol = https

    # The http(s) port to use
    http_port = 8443

    # The public facing domain name used to access grafana from a browser
    # Note: You may need to update this depending on your setup
    domain = localhost

    # Serve Grafana from subpath specified in `root_url` setting. By default it is set to `false` for compatibility reasons.
    # Set back to false if using a proxy due to above said 'compatibility' reasons
    serve_from_sub_path = true

    # Log web requests
    router_logging = true # Optional

    # https certs & key file
    # NOTE: You can alter the Containerfile to copy over your cert file and key into /etc/grafana
    #
    # Just be sure to either change the file names, or copy over the cert and key files with <hostname>.crt, <hostname>.key
    # naming convention.
    cert_file = ${HOSTNAME}.crt
    cert_key = ${HOSTNAME}.key
    ```
- LDAP - to enable LDAP, set `enabled = true` under the section `[auth.ldap]`
    
    ```ini
    [auth.ldap]
    enabled = true
    ```
    
    Additionally, you would need to setup the `ldap.toml` file in order to authenticate to your LDAP server.

### `ldap.toml`
-  LDAP setup will not be covered in this Git repo.
- You can find information on setting up LDAP within the Grafana docs - [here](https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/ldap/).

## Provisioning Grafana
The following items can be provisioned as code for Grafana:
- dashboards
- datasources
- plugins
- alerting
- and more!

If this Git repo does not include a specific provisioning resource, you can create a new folder inside of the Git repo path `grafana/provisioning`, which can then include its provisioning.yaml file.

See Grafana documentation on usage [here](https://grafana.com/docs/grafana/latest/administration/provisioning/).

> NOTE: You CAN use environment variables in ALL provisioning configuration. The syntax for an environment variable can either be `$ENV_VAR_NAME` or `${ENV_VAR_NAME}`.

### Dashboard Provisioning
Located in `grafana/provisioning/dashboards`, the `dashboards.yaml` file is explained in the code block below:

```yaml
# Config file version
apiVersion: 1

providers:
    # Unique provider name. Required.
  - name: dashboards
    # Provider type. Default to 'file'
    type: file
    # How often Grafana will scan for changed dashboards
    updateIntervalSeconds: 1800
    # Disable/enable deletion of provisioned dashboards from the UI
    disableDeletion: true
    # Allow updating provisioned dashboards from the UI
    allowUIUpdates: true
    options:
      # Path to dashboard files on disk.
      # This is set as an environment variable, which can be updated in the Containerfile
      path: ${GF_PATHS_DASHBOARDS}
      # Use folder names from filesystem to create folders in Grafana
      # This way, Grafana will automatically create and organize dashboards by the directories they are kept within Git
      foldersFromFilesStructure: true
```

The folder structure is as follows:

```shell
${GF_PATHS_DASHBOARDS} # /var/lib/grafana/dashboards, or whatever path is defined in the environment variable
├── /Map
│   ├── /earthquakes_by_day.json
└── /Statistics
    └── /titanic_metrics.json
```