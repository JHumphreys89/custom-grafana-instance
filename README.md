# Grafana - Provisioning as Code
This custom Grafana image accomplishes the following:
- Sets up environment variables for paths used in Grafana configuration
- Installs a custom set of packages and plugins within the Container
- Sets ownership, permissions of directories specified in environment variables
- Copies the provisioning/config files, and custom dashboards from the Git repository directly into the Container (no mounts required)

> NOTE: If wanting to use Docker instead, simply replace `podman` in all commands with `docker`!

## Initial Setup Instructions
Using the steps below, you will be:
1. Clone the Git repo
2. Build the podman (or Docker) image
3. Run the Container

**Before beginning instructions, ensure that you have cloned a copy of this repository and are checked out on the `main` branch.**

### 1. Build the podman image
Run the following command, which tells podman to build an image using the Containerfile in the _root_ `git-grafana` directory (.) and tag it with the name grafana-custom:

```shell
cd git-grafana
podman build -t grafana-custom .
```

### 2. Run the Container
Once the image is built, you can run a Container from it. This command will:

- `-d`: Run the Container in detached mode (in the background).
- `--name grafana-server`: Assign a specific name to the Container (`grafana-server`) for easy reference.
- `-p 3000:3000` & `-p 9090:9090`: Map ports 3000 and 9090 on your host machine to ports 3000 and 9090 (respectively) inside the Container.

| Port | Description                                 |
|:-----|:--------------------------------------------|
| 3000 | Grafana 'http' port                         |
| 9090 | Prometheus URL for scraping Grafana metrics |

- `grafana-custom`: Specifies the name of the image you just built.

```shell
podman run -d --name grafana-server -p 3000:3000 -p 9090:9090 grafana-custom
```

#### _Setting or Resetting an Admin Password for the Grafana Admin Account:_

- If you would like to set a password for the admin user, you can add the `-e GF_ADMIN_PASSWORD=""` flag inside of the above `podman run` command. 
- If you need to retrieve the GF Admin password, use the following podman command:
```shell
podman exec -t grafana-server printenv GF_ADMIN_PASS
```
- If you need to set a new password, you can use the `grafana-cli` command within the Container:
```shell
podman exec -t grafana-server grafana-cli admin reset-admin-password \<new_password\>
```

After running the podman run command, Grafana should be accessible in your web browser at `http://localhost:3000`

#### Start Prometheus as a background process inside of the Container

In order to have Prometheus scrape metrics for the Container that is running Grafana, you will need to run the command:
```shell
podman exec -d grafana-server /usr/bin/prometheus --config.file=/etc/grafana/prometheus.yml
```
> Note:
> - Make sure to include `-d` in order to run the executable in detached mode.
> - If you changed the variable for `GF_PATHS_CONFIG`, you will need to update the `--config.file` location so that Prometheus can pick up the correct `prometheus.yml` file.

### 3. Signing into Grafana
To sign into Grafana, you can use the `GF_ADMIN_USER` (default is 'admin') and password set in the previous step to sign in as the Grafana Admin account. If unable to sign in as the GF Admin, you will need to reset the password (see step 2 under [_"Setting or Resetting an Admin Password for the Grafana Admin Account"_](#setting-or-resetting-an-admin-password-for-the-grafana-admin-account) for assistance.)

Alternatively, you can also create an account to sign in as a new user (without admin capabilities).

## Making Changes While Container is Running
Run the following podman command to execute commands inside the newly running Grafana container:

```shell
podman exec -it grafana-server /bin/sh
```

## Additional Notes Regarding the Grafana Container
- If you need to access the container as root (not recommended), run the command: `podman exec -it --user root grafana-server /bin/sh`.

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
If needing to (re)start the `grafana-server`, remember to re-run the `exec` command for Prometheus, so that metrics on the instance can continue to be gathered.

## Plugins and Grafana

### Method 1: Git
If you want to keep the plugin itself in Git, you can do that by creating a plugins directory somewhere within the repository (after setting up a fork) and then simply upload the plugin files.

### Method 2: `wget`, `unzip`/`tar -x` in Containerfile
However, you can also just download the plugins via the `wget` command, and then use `unzip` or `tar -x` to extract the plugin within the Containerfile OR the Container itself.

### Method 3: Pre-download, `COPY` using Containerfile
You could find and install the plugin, and then use `COPY` inside of the Containerfile to move the file(s) into the Container during buildtime. Here is an example:
```dockerfile
COPY <local/path/to/files> ${GF_PATHS_PLUGINS}
```

You can also provision plugins (explained in the [provisioning steps](grafana/README.md#provisioning-grafana)). The provisioning feature essentially allows you to configure your plugins once they have been installed by one of the methods above.

## Configuring & Provisioning Grafana

See [README](grafana/README.md) file in the grafana directory for instructions.

## Adding Additional Dashboards

For additional dashboards:
- You can create your own using the Grafana UI (`localhost:3000` or applicable URL) once the Container has been setup.
- You can also hit up [Grafana dashboards](https://grafana.com/grafana/dashboards/), which is a dump of community-made dashboards. You can filter on Data Sources, Panels, Collector Types, and more.
- To pre-provision Dashboards, you can use the `Export` option within the Grafana UI to copy and paste the JSON code into a new `<dashboard_name>.json` file inside of the `grafana/dashboards/<folder_name>` section of the Git repository.

> Note: If you plan to create Dashboards that use a new plugin/datasource, remember Grafana UI give the datasource a randomly-assigned string of characters as the UID (which the dashboard will reference). It is recommended to provision the datasource as well, so that the UID will stay consistent - especially if creating multiple instances of Grafana (dev, prod, etc.), or you plan on deprovisioning & provisioning the Container or Image often.

## License
This project uses the [MIT License](./LICENSE).