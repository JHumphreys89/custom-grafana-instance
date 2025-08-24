# Grafana - Provisioning as Code
This custom Grafana image accomplishes the following:
- Sets up environment variables for paths used in Grafana configuration
- Installs a custom set of packages and plugins within the Container
- Sets ownership, permissions of directories specified in environment variables
- Copies the provisioning/config files, and custom dashboards from the Git repository directly into the Container (no mounts required)

> NOTE: If wanting to use Docker instead, simply replace `podman` in all commands with `docker`!

## Initial Setup Instructions

**Before beginning instructions, ensure that you have cloned a copy of this repository and are checked out on the `main` branch.**

### 1. Build the podman image
Run the following command, which tells podman to build an image using the Containerfile in the _root_ `git-grafana` directory (.) and tag it with the name grafana-custom:

```shell
cd git-grafana
podman build -t grafana-custom .
```

### 2. Run the container
Once the image is built, you can run a container from it. This command will:

- `-d`: Run the container in detached mode (in the background).
- `--name grafana-server`: Assign a specific name to the container (`grafana-server`) for easy reference.
- `-p 3000:3000`: Map port 3000 on your host machine to port 3000 inside the container. This allows you to access Grafana from your host's (device running the container) web browser.
- `grafana-custom`: Specifies the name of the image you just built.

```shell
podman run -d --name grafana-server -p 3000:3000 -p 9090:9090 grafana-custom
```

#### **Setting an Admin Password for the Grafana Admin Account:**

- If you would like to set a password for the admin user, you can add the `-e GF_ADMIN_PASSWORD=""` flag inside of the above `podman run` command. 
- To have a randomly generated password, you can use `-e GF_ADMIN_PASSWORD="$(mktemp -u XXXXXXXXXX)"`. This will generate a random string of X characters. You can then obtain the password by using the following podman command:

```shell
podman exec grafana-server printenv GF_ADMIN_PASS
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

## Plugins and Grafana

### Method 1: Git
If you want to keep the plugin itself in Git, you can do that by creating a plugins directory somewhere within the repository and then simply upload the plugin files.

### Method 2: `wget`, `unzip` in Container(file)
However, you can also just download the plugins via the `wget` command, and then use `unzip` to extract the plugin within the Containerfile OR the Container itself.

You can also provision plugins (explained in the provisioning steps below). The provisioning feature essentially allows you to configure your plugins once they have been installed by one of the methods above.

## Configuring & Provisioning Grafana

See [README](grafana/README.md) file in the grafana directory for instructions.

## License
This project uses the [MIT License](./LICENSE).