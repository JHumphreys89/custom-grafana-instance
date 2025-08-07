# Grafana - Provisioning as Code
This custom Grafana image accomplishes the following:
- Sets up environment variables for paths used in Grafana configuration
- Installs a custom set of apps within the Container (_and comes in around 100MB smaller than the official grafana/grafana image_)
- Sets ownership, permissions of directories specified in environment variables
- Copies the provisioning/config files, and custom dashboards from the Git repository directly into the Container (no mounts required)

> NOTE: If wanting to use Docker instead, simply replace `podman` in all commands with `docker`!

## Initial Setup Instructions

### 1. Build the podman image
Run the following command, which tells podman to build an image using the Containerfile in the currect directory (.) and tag it with the name grafana-custom:

```shell
podman build -t grafana-custom .
```

### 2. Run the container
Once the image is built, you can run a container from it. This command will:

- `-d`: Run the container in detached mode (in the background).
- `--name grafana-server`: Assign a specific name to the container (`grafana-server`) for easy reference.
- `-p 3000:3000`: Map port 3000 on your host machine to port 3000 inside the container. This allows you to access Grafana from your host's (device running the container) web browser.
- `grafana-custom`: Specifies the name of the image you just built.

```shell
podman run -d --name grafana-server -p 3000:3000 grafana-custom
```

After running the podman run command, Grafana should be accessible in your web browser at `http://localhost:3000`

### 3. Signing into Grafana
To sign into Grafana, you can enter `admin`/`admin` as your username and password to sign in as the Grafana Admin account. It should prompt you to create a new password upon a successful login attempt.

## Making Changes While Container is Running
Run the following podman command to execute commands inside the newly running Grafana container:

```shell
podman exec -it grafana-server /bin/sh
```

## Additional Notes Regarding the Grafana Container
- If you need to access the container as root, run the command: `podman exec -it --user root grafana-server /bin/sh`.

- Alpine containers are light-weight. If you need to install any other commands/applications, use the `apk add` command.

- Containers do not use service/systemctl commands. <br>
  To:
    * Start Grafana: 
    ```shell
    podman start grafana-server
    ```
    * Stop Grafana: 
    ```shell
    podman stop grafana-server
    ```
    * Restart Grafana: 
    ```shell
    podman restart grafana-server
    ```

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

## Plugins

### Method 1: Git
If you want to keep the plugin itself in Git, you can do that by creating a plugins directory somewhere within the repository and then simply upload the plugin files.

### Method 2: `wget`, `unzip` in Container(file)
However, you can also just download the plugins via the `wget` command, and then use `unzip` to extract the plugin within the Containerfile OR the Container itself.

You can also provision plugins (explained in the provisioning steps below). The provisioning feature essentially allows you to configure your plugins once they have been installed by one of the methods above.

## Provisioning
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
├── /General
│   ├── /common_dashboard.json
│   └── /network_dashboard.json
└── /application
    ├── /requests_dashboard.json
    └── /resources_dashboard.json
```

## License
This project uses the [MIT License](./LICENSE).