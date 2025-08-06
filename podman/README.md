# Custom Grafana Container

> NOTE: The Grafana image in this Git directory comes in at around 759MB in size, which is around 100MB smaller than the grafana/grafana:main-ubuntu image from [Docker Hub](http://hub.docker.com/r/grafana/grafana).
> This version of Grafana is also more customizable than the one you would find in Docker Hub.

## Steps

### 1. Save the `Containerfile`
Make sure that the `Containerfile` content from the podman directory in this repo is saved in a file named `Containerfile` (if new to containers, this does NOT have a file extension association) and placed in an empty directory in order to build the image:

```shell
mkdir grafana-image
cd grafana-image
# Now create a new file named Containerfile (again, with no ext) and paste contents
# vi commands would be tapping the [Ins] button and then right-click to paste, followed by the keys ':wq' to save changes
vi Containerfile
```

### 2. Build the podman image
Run the following command, which tells podman to build an image using the Containerfile in the currect directory (.) and tag it with the name grafana-custom:

```shell
podman build -t grafana-custom .
```

### 3. Run the container
Once the image is built, you can run a container from it. This command will:

- `-d`: Run the container in detached mode (in the background).
- `--name grafana-server`: Assign a specific name to the container (`grafana-server`) for easy reference.
- `-p 3000:3000`: Map port 3000 on your host machine to port 3000 inside the container. This allows you to access Grafana from your host's (device running the container) web browser.
- `grafana-custom`: Specifies the name of the image you just built.

```shell
podman run -d --name grafana-server -p 3000:3000 grafana-custom
```

After running the podman run command, Grafana should be accessible in your web browser at `http://localhost:3000`

### 4. Enter the container
Run the following podman command to execute commands inside the newly running Grafana container:

```shell
podman exec -it grafana-server /bin/sh
```

### 5. Signing into Grafana
To sign into Grafana, you can enter `admin`/`admin` as your username and password to sign in as the Grafana Admin account. It should prompt you to create a new password upon a successful login attempt.

## Note
1. If you need to access the container as root, run the command: `podman exec -it --user root grafana-server /bin/sh`.

2. Alpine containers are light-weight. If you need to install any other commands/applications, use the `apk add` command.

3. Containers do not use service/systemctl commands. To:
- Start Grafana: `podman start grafana-server`
- Stop Grafana: `podman stop grafana-server`
- Restart Grafana: `poman restart grafana-server`