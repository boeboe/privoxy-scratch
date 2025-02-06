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
$ docker run --rm --network host boeboe/privoxy-scratch
```

Once the docker container has finished starting, you can test it with the following command:

```console
$ curl --socks5 localhost:9050 --socks5-hostname localhost:9050 https://check.torproject.org/api/ip
```

> **NOTE:** If you use do not use host network, you need to force tor to listen on `0.0.0.0` instead of the default `127.0.0.1`

In order to pass a `torrc` configuration file and modify the exposed proxy port:

```console
$ cat torrc 
Log notice stdout
HTTPTunnelPort 0.0.0.0:9080
SocksPort 0.0.0.0:9050
MaxCircuitDirtiness 30

$ docker run -p 8050:9050 -p 8080:9080 -v "$(pwd)"/torrc:/torrc boeboe/privoxy-scratch tor -f torrc

$ curl --socks5 localhost:8050 --socks5-hostname localhost:8050 https://check.torproject.org/api/ip
$ curl --proxy localhost:8080 https://check.torproject.org/api/ip
```

## Manual page

Man page of version [0.4.8.14](https://dist.torproject.org/tor-0.4.8.14.tar.gz) can be found [here](./MANPAGE.md).

## Request configuration change

Please use this [link](https://github.com/boeboe/privoxy-scratch/issues/new/choose) (GitHub account required) to suggest a change in this image configuration.
