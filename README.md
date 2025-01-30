# Nginx-proxy
[![Test](https://github.com/nginx-proxy/nginx-proxy/actions/workflows/test.yml/badge.svg)](https://github.com/nginx-proxy/nginx-proxy/actions/workflows/test.yml)
[![GitHub release](https://img.shields.io/github/v/release/nginx-proxy/nginx-proxy)](https://github.com/nginx-proxy/nginx-proxy/releases)
[![nginx 1.27.3](https://img.shields.io/badge/nginx-1.27.3-brightgreen.svg?logo=nginx)](https://nginx.org/en/CHANGES)
[![Docker Image Size](https://img.shields.io/docker/image-size/nginxproxy/nginx-proxy?sort=semver)](https://hub.docker.com/r/nginxproxy/nginx-proxy "Click to view the image on Docker Hub")
[![Docker stars](https://img.shields.io/docker/stars/nginxproxy/nginx-proxy.svg)](https://hub.docker.com/r/nginxproxy/nginx-proxy "DockerHub")
[![Docker pulls](https://img.shields.io/docker/pulls/nginxproxy/nginx-proxy.svg)](https://hub.docker.com/r/nginxproxy/nginx-proxy "DockerHub")
<img src="https://img.shields.io/badge/maintained%3F-yes-brightgreen.svg" alt="Maintained - Yes" />



This is a copy of the [original repo](https://github.com/ionghitun/nginx-proxy) with some modifications to make it easier to use.
Docker-compose for [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) which is a simple solution for proxying requests to multiple containers.
This repo also includes:
 - [acme-companion](https://github.com/nginx-proxy/acme-companion)
 - [self-signed-companion](https://github.com/sebastienheyd/docker-self-signed-proxy-companion)
 - [mailcatcher](https://github.com/sj26/mailcatcher)
 - [opensearch](https://github.com/opensearch-project)
 - [elasticsearch](https://github.com/elastic/elasticsearch)
 - [phpmyadmin](https://github.com/phpmyadmin/phpmyadmin)
 - [portainer](https://github.com/portainer/portainer)

Still to come:
 - [traefik](https://github.com/traefik/traefik)
 - [minio](https://github.com/minio/minio)
 - [cloudflare-companion](https://github.com/tiredofit/docker-nginx-proxy-cloudflare-companion)

## Introduction

This project provides a convenient wrapper for `nginx-proxy` and `acme-companion`, allowing you to easily develop multiple projects locally with virtual hosts using Docker. It is also ready for live deployment. Additionally, it includes `phpmyadmin` and `mailcatcher` for quick debugging, and a global `opensearch` instance for all projects to reduce unnecessary RAM allocation per project.

## Prerequisites

- Docker
- Docker Compose

## Project Structure

```plaintext
.
├── bin/             # CLI commands
├── certs/           # SSL certificates
├── conf/            # Custom nginx configuration
├── dhparam/         # Diffie-Hellman parameters
├── env/             # Docker environment variables
├── html/            # Default web root
├── images/          # Custom images
├── vhost/           # Virtual host templates
├── README.md        # Project documentation
├── Makefile         # Makefile for CLI commands
├── .env             # Environment variables
├── .gitignore       # Git ignore file
└── docker-compose.yml
```

## CLI Commands

Use the following CLI commands:

- **root**: Run any CLI command as root without going into the bash prompt.
- **bash**: Drop into the bash prompt of your Docker container.
- **cli**: Run any CLI command without going into the bash prompt.
- **docker-compose**: Support V1 (`docker-compose`) and V2 (`docker compose`) docker compose command, and use custom configuration files.
- **docker-stats**: Display status for CPU, memory usage, and memory limit of currently-running Docker containers.
- **log**: Monitor the log files. Pass no params to tail all files.
- **restart**: Stop and then start all containers.
- **setup**: Create the `.env` file and set the environment variables.
- **start**: Start all containers.
- **status**: Check the container status.
- **stop**: Stop all project containers.
- **update**: Update your project to the latest version.

## Environment Variables

The following environment variables are used in the `.env` file:

- **NGINX_PROXY_VERSION**: Version of the nginx-proxy image to use.
- **ACME_COMPANION_VERSION**: Version of the acme-companion image to use.
- **SELF_SIGNED_VERSION**: Version of the self-signed companion image to use.
- **COMPOSE_PROFILES**: Compose profiles to use. Possible values: `acme`, `self-signed`.
- **USER_ID**: User ID for file permissions.
- **GROUP_ID**: Group ID for file permissions.

> [!IMPORTANT]
>
> #### A note on `latest` and `alpine`:
>
> It is not recommended to use the `latest` (`nginxproxy/nginx-proxy`, `nginxproxy/nginx-proxy:latest`) or `alpine` (`nginxproxy/nginx-proxy:alpine`) tag for production setups.
>
> [Those tags point](https://hub.docker.com/r/nginxproxy/nginx-proxy/tags) to the latest commit in the `main` branch. They do not carry any promise of stability, and using them will probably put your nginx-proxy setup at risk of experiencing uncontrolled updates to non backward compatible versions (or versions with breaking changes). You should always specify the version you want to use explicitly to ensure your setup doesn't break when the image is updated.

### Compose Profiles

The following compose profiles are available:

- **acme**: Use this profile to enable the acme companion for automatic SSL certificate generation.
- **self-signed**: Use this profile to enable the self-signed companion for local development with self-signed certificates.

To use a profile, set the `COMPOSE_PROFILES` variable in the `.env` file. For example:

```dotenv
COMPOSE_PROFILES=acme
```

### Installation notes

- Clone project
- Run the setup script: `./bin/setup`
- Edit the `.env` file and set the environment variables
- Start the containers: `./bin/start`

### Documentation:

- In `conf/custom.conf` you can add any custom configuration for nginx.

Example on how to use on containers:

    services:
        web:
            ...
            ports:
                - 80
            ...
            environment:
                VIRTUAL_HOST: example.com
                VIRTUAL_PORT: 80
                LETSENCRYPT_HOST: example.com
                LETSENCRYPT_EMAIL: mail@example.com
            ...
            networks:
                ...
                - nginx-proxy

You can use multiple domains/subdomains:

    services:
        web:
            ...
            build:
                context: ./
                dockerfile: web/Dockerfile
            ports:
                - 80
            ...
            environment:
                VIRTUAL_HOST: example.com,sub.example.com,example2.com
                VIRTUAL_PORT: 80
                LETSENCRYPT_HOST: example.com,sub.example.com,example2.com
                LETSENCRYPT_EMAIL: mail@example.com
            ...
            networks:
                ...
                - nginx-proxy

When using self-signed companion you need to add `SELF_SIGNED_HOST: "example.com"` environment variable as well

- In `web/Dockerfile` you can include a conf where you define your servers, wildcards are not yet supported by acme
  companion.
- Self-signed companion should be used only on a local environment.
- To use self-signed companion change `COMPOSE_PROFILES` to `self-signed` in .env

## Trust self-signed certificates

To avoid the alert "your connection is not private" please check self-signed repo: https://github.com/sebastienheyd/docker-self-signed-proxy-companion

## Use certificates with vite server

In order to use certification in an application you need to change ownership to `<user>:<group>` for folder `certs` after certificates generation and map certs as read only volume
where you want to use certs.



### Additional documentation

Please check the [docs section](https://github.com/nginx-proxy/nginx-proxy/tree/main/docs).

### Email / Mailcatcher

View emails sent locally through Mailcatcher by visiting [http://{yourdomain}:1080](http://{yourdomain}:1080). In order to use mailcatcher, set the mailserver host to `mailcatcher` and set port to `1025`. Note that this port (`1025`) is different from the mailcatcher interface to read the emails (`1080`).

Alternative tools to test emails and get some metrics: [mailtrap](https://mailtrap.io/)

### PhpMyAdmin

PhpMyAdmin is built into the project file. Simply open `http://localhost:8080` in a web browser.

These credentials can be used to log in to PhpMyAdmin are specified in each project .env file.

### Troubleshooting
- **Error: SSL certificate not working**  
  Check if `COMPOSE_PROFILES` is set correctly in the `.env` file.

- **Error: `nginx-proxy` container keeps restarting**  
  Ensure you don't have conflicting ports on the host machine.

- **Error: Let's Encrypt SSL certificates not being generated**  
  Verify your domain is properly pointed to the server's IP address and publicly accessible.

- **Error: `docker-compose` command not found**  
  Ensure you have Docker Compose installed.

### Contributions
Want to make this project better? Feel free to submit a PR or open an issue. We promise not to ignore it (too much).

### Contact Information
If you're stuck or have questions:
- Option 1: Read the docs until you question your life choices.
- Option 2: Open an issue and pray someone answers before the next millennium.
- Option 3: Offer cookies or coffee, and maybe, just maybe, someone will help.
