# Privoxy-Scratch Container

Run [PRIVOXY](https://www.privoxy.org/) conveniently from a docker scratch container.
 - Containers available on [DockerHub](https://hub.docker.com/r/boeboe/privoxy-scratch)
 - Sources available on [GitScm](https://www.privoxy.org/git/privoxy.git)
 - Binary downloads on [Sourceforge](https://sourceforge.net/projects/ijbswa)

[![Docker Build](https://github.com/boeboe/privoxy-scratch/actions/workflows/docker-image.yml/badge.svg)](https://github.com/boeboe/privoxy-scratch/actions/workflows/docker-image.yml)
[![Docker Stars](https://img.shields.io/docker/stars/boeboe/privoxy-scratch)](https://hub.docker.com/r/boeboe/privoxy-scratch)
[![Docker Pulls](https://img.shields.io/docker/pulls/boeboe/privoxy-scratch)](https://hub.docker.com/r/boeboe/privoxy-scratch)
[![Docker Image Size](https://img.shields.io/docker/image-size/boeboe/privoxy-scratch)](https://hub.docker.com/r/boeboe/privoxy-scratch)
[![Docker Version](https://img.shields.io/docker/v/boeboe/privoxy-scratch?sort=semver)](https://hub.docker.com/r/boeboe/privoxy-scratch)

## Usage

```console
$ docker run -p 8118:8118 -v "$(pwd)"/config:/etc/privoxy boeboe/privoxy-scratch
```

Once the docker container has finished starting, you can test it with the following command:

```console
$ curl --proxy "http://localhost:8118" http://config.privoxy.org
```

> **NOTE:** If you use do not use host network, you need to force tor to listen on `0.0.0.0` instead of the default `127.0.0.1`

## Manual page

Man page of version [4.0.0](https://www.privoxy.org/sf-download-mirror/Sources/4.0.0%20%28stable%29/privoxy-4.0.0-stable-src.tar.gz) can be found [here](./MANPAGE.md).

## Request configuration change

Please use this [link](https://github.com/boeboe/privoxy-scratch/issues/new/choose) (GitHub account required) to suggest a change in this image configuration.
