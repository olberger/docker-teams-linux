This project is fully inspired of Marc Douchement's [docker-zoom-us](https://github.com/mdouchement/docker-zoom-us), which in turn was inspired by [sameersbn](https://github.com/sameersbn) [Skype](https://github.com/sameersbn/docker-skype)'s containerization.

# olberger/teams

# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container image with [Teams](https://www.microsoft.com/en-us/microsoft-365/microsoft-teams/download-app) for Linux with support for audio/video calls.

The image uses [X11](http://www.x.org) and [Pulseaudio](http://www.freedesktop.org/wiki/Software/PulseAudio/) unix domain sockets on the host to enable audio/video support in Teams. These components are available out of the box on pretty much any modern linux distribution.

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](https://github.com/olberger/docker-teams/issues?q=is%3Aopen+is%3Aissue).

# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/olberger/teams) and is the recommended method of installation.

```bash
docker pull olberger/teams:latest
```

Alternatively you can build the image yourself.

```bash
docker build -t olberger/teams github.com/olberger/docker-teams
```

With the image locally available, install the wrapper scripts by running the following as root:

```bash
docker run -it --rm \
  --volume /usr/local/bin:/target \
  olberger/teams:latest install
```

This will install a wrapper script to launch `teams`.

## Starting Teams

Launch the teams-wrapper script to enter a shell inside the Docker container

```bash
teams-wrapper bash
```

Then the prompt should be displayed like:
```
Adding user `teams' to group `sudo' ...
Adding user teams to group sudo
Done.
bash
teams@0b2fefbf45d2:~$
```

then type `teams`.


> **Note**
>
> If Teams is installed on the the host then the host binary is launched instead of starting a Docker container. To force the launch of Teams in a container use the `teams-wrapper` script. For example, `teams-wrapper teams` will launch Teams inside a Docker container regardless of whether it is installed on the host or not.


## How it works

The wrapper scripts volume mount the X11 and pulseaudio sockets in the launcher container. The X11 socket allows for the user interface display on the host, while the pulseaudio socket allows for the audio output to be rendered on the host.

When the image is launched the following directories are mounted as volumes

- `${HOME}/.config`
- `XDG_DOWNLOAD_DIR` or if it is missing `${HOME}/Downloads`
- `XDG_DOCUMENTS_DIR` or if it is missing `${HOME}/Documents`

This makes sure that your profile details are stored on the host and files received via Teams are available on your host in the appropriate download directory.

**Don't want to expose host's folders to Teams?**

Add `TEAMS_HOME` environment variable to namespace all Teams folders:

```sh
export TEAMS_HOME=${HOME}/teams
```


# Maintenance

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull olberger/teams:latest
  ```

  2. Run `install` to make sure the host scripts are updated.

  ```bash
  docker run -it --rm \
    --volume /usr/local/bin:/target \
    olberger/teams:latest install
  ```

## Uninstallation

```bash
docker run -it --rm \
  --volume /usr/local/bin:/target \
  olberger/teams:latest uninstall
```

