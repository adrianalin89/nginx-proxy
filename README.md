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
 - [mailpit](https://github.com/axllent/mailpit)
 - [opensearch](https://github.com/opensearch-project)
 - [elasticsearch](https://github.com/elastic/elasticsearch)
 - [phpmyadmin](https://github.com/phpmyadmin/phpmyadmin)

Still to come:
 - [traefik](https://github.com/traefik/traefik)
 - [minio](https://github.com/minio/minio)
 - [cloudflare-companion](https://github.com/tiredofit/docker-nginx-proxy-cloudflare-companion)

## Introduction

This project provides a convenient wrapper for `nginx-proxy` and `acme-companion`, allowing you to easily develop multiple projects locally with virtual hosts using Docker. It is also ready for live deployment. Additionally, it includes `phpmyadmin` and `mailpit` for quick debugging, and a global `opensearch` instance for all projects to reduce unnecessary RAM allocation per project.

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
├── docker-compose.yml
└── compose.override.yaml  # Optional, machine specific, not committed (see compose.override.yaml.example)
```

## CLI Commands

Use the following CLI commands:

- **root**: Run any CLI command as root without going into the bash prompt.
- **bash**: Drop into the bash prompt of your Docker container.
- **cleanup**: Show unused networks (never the shared ones, never networks of stopped containers), dangling images, build cache and unused volumes; `bin/cleanup --force` removes them asking y/n for each network, each dangling image and the build cache (`--force --yes` without asking). Volumes are only listed.
- **cli**: Run any CLI command without going into the bash prompt.
- **docker-compose**: Support V1 (`docker-compose`) and V2 (`docker compose`) docker compose command; loads `docker-compose.yml` and, when present, `compose.override.yaml`.
- **log**: Monitor the log files. Pass no params to tail all files.
- **restart**: Stop and then start all containers.
- **setup**: Create the `.env` file and set the environment variables.
- **sites**: List the sites served by the proxy (containers on the `nginx-proxy` network with a `VIRTUAL_HOST`): container, URL, port, certificate (self-signed / Let's Encrypt and expiry) and basic auth (`proxy` = `htpasswd/<domain>`, `app` = enabled inside the container).
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

### Image versions

The versions of all images are pinned in `docker-compose.yml` (ex. `${RABBITMQ_VERSION:-4.1}`), so updating a service is a change in this repository followed by `git pull` and `bin/start` on every server. `.env` can override them for one machine (`NGINX_PROXY_VERSION`, `ACME_COMPANION_VERSION`, `SELF_SIGNED_VERSION`, `MAILPIT_VERSION`, `OPENSEARCH_VERSION`, `PHPMYADMIN_VERSION`, `RABBITMQ_VERSION`, all commented out in `.env.example`). The OpenSearch image is tagged with its version, a new `OPENSEARCH_VERSION` is built automatically by the next `bin/start`.

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

### Reach a site from inside a container (SSR)

**When you need it.** Only when code running *inside a container* calls another local site by its `.test` domain over HTTPS. Typical case: a headless front (Next.js, Nuxt, a Node or PHP service) that renders on the server and calls the backend API of another project, ex. `https://api.myshop.test/graphql`. The browser is fine, but the server-side request fails with:

```text
connect ECONNREFUSED 127.0.0.1:443
```

**Why.** The `.test` domains point to `127.0.0.1` in the host `/etc/hosts`. Docker's resolver passes names it doesn't know to the host, so the container gets `127.0.0.1` too, and inside a container `127.0.0.1` is the container itself. Calls between containers of the *same* project (by container name, ex. `myshop-php:9000`) are not affected, and you don't need this when the calling container goes over plain HTTP to a container name.

**How.** Give the proxy the called domains as network aliases on the `nginx-proxy` network. Every container on that network then resolves them to the proxy, which serves them with the usual certificate.

1. In this repository, copy the sample and list the domains that are called from inside containers:

   ```bash
   cp compose.override.yaml.example compose.override.yaml
   ```

   ```yaml
   services:
       proxy-nginx-proxy:
           networks:
               default:
                   aliases:
                       - api.myshop.test
                       - api.otherproject.test
   ```

   `compose.override.yaml` is machine specific and not committed; `bin/docker-compose` loads it when it exists, so the aliases survive every proxy update.

2. Apply it: `bin/start` (recreates `proxy-nginx-proxy`, all sites are down for a few seconds).

3. In the project that *makes* the calls, the container must be on the `nginx-proxy` network and trust the local CA (`certs/nginx-proxy-ca.crt`), ex. for a Node container:

   ```yaml
   services:
       front-node:
           volumes:
               - ${PROXY_CA_CERT}:/usr/local/share/ca-certificates/proxy-ca.crt:ro
           environment:
               NODE_EXTRA_CA_CERTS: /usr/local/share/ca-certificates/proxy-ca.crt
           networks:
               - default
               - nginx-proxy

   networks:
       nginx-proxy:
           external: true
   ```

   with `PROXY_CA_CERT=/path/to/nginx-proxy/certs/nginx-proxy-ca.crt` in that project's `.env` (PHP / curl containers: copy the CA to `/usr/local/share/ca-certificates/` and run `update-ca-certificates`).

4. Check from the calling container:

   ```bash
   docker exec <container> getent hosts api.myshop.test    # must show the proxy IP, not 127.0.0.1
   docker exec <container> node -e "fetch('https://api.myshop.test').then(r => console.log(r.status))"
   ```

Still `127.0.0.1`? The container is not on the `nginx-proxy` network, or the proxy was not recreated after the change. A certificate error means the CA from step 3 is missing. Don't add the aliases by hand with `docker network connect --alias`: they are lost the next time the proxy is recreated.

### Behind a WAF or load balancer (real client IP)

When the server sits behind a WAF / load balancer, every request reaches the proxy from that device and the sites log its address instead of the client's. The device puts the client IP in `X-Forwarded-For`; tell nginx to trust it for that address only:

1. `cp conf/realip.conf.sample conf/realip.conf`, set the device's address in `set_real_ip_from` (one line per address, ex. both nodes of an HA pair; find it in `bin/log proxy-nginx-proxy` or the access log). `conf/realip.conf` is machine specific and not committed (`conf/.gitignore`).
2. `docker exec proxy-nginx-proxy nginx -t && docker exec proxy-nginx-proxy nginx -s reload`.

The proxy now logs the client IP and sends it to the sites in `X-Real-IP`. A site's own nginx (ex. a Magento container) sees the proxy as client, so it needs the same for the proxy network:

```nginx
set_real_ip_from 172.18.0.0/16;   # subnet of the nginx-proxy network: docker network inspect nginx-proxy
real_ip_header X-Real-IP;
```

Only trust addresses that can't be reached by clients directly, otherwise anyone can fake their IP with an `X-Forwarded-For` header.

### Email / Mailcatcher

Every email sent by the projects is caught by [Mailpit](https://mailpit.axllent.org/): set the mail server host to `mailcatcher` and port `1025` (the m2docker PHP images already do it through msmtp; `mailcatcher` is a network alias of the `mailpit` container, so older projects keep working). Read the emails on the `MAILCATCHER` domain from `.env` (default `https://mail.test`). Emails are stored in the `mailpitdata` volume (last 5000).

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



htpasswd -c ./htpasswd/[foo.bar] [username]   replace [foo.bar] and [username] whit domain and username
