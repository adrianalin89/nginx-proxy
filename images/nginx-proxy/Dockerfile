# syntax=docker/dockerfile:1
# nginx-proxy with a patched nginx: the official nginx-proxy image (same docker-gen,
# forego, template and entrypoint) moved onto a newer official nginx image.
#
# Why: CVE-2026-123007 / CVE-2026-123633 (nginx HTTP/2, fixed in nginx 1.30.7 / 1.31.9)
# and no nginx-proxy release ships a fixed nginx yet (1.11.6 / latest = nginx 1.31.6).
# Go back to `image: nginxproxy/nginx-proxy:<version>` in docker-compose.yml once one does.
#
# Build args: NGINX_PROXY_VERSION (template/behaviour, default 1.7 as before),
#             NGINX_VERSION (official nginx image tag, Debian).
# Same as upstream: /app (entrypoint, Procfile, nginx.tmpl, dhparam), docker-gen, forego,
# nginx.conf with the toplevel.conf.d include. Only nginx itself (and Debian) changes.
ARG NGINX_PROXY_VERSION=1.7
ARG NGINX_VERSION=1.30.7

FROM docker.io/nginxproxy/nginx-proxy:${NGINX_PROXY_VERSION} AS upstream

FROM docker.io/library/nginx:${NGINX_VERSION}

ARG NGINX_PROXY_VERSION
# acme-companion reads DOCKER_GEN_VERSION (the value itself does not matter)
ENV NGINX_PROXY_VERSION=${NGINX_PROXY_VERSION} \
    DOCKER_GEN_VERSION=unknown \
    DOCKER_HOST=unix:///tmp/docker.sock

# nginx.conf of nginx-proxy (toplevel.conf.d include, worker_connections 10240,
# worker_rlimit_nofile 20480) + the directories it expects
COPY --from=upstream /etc/nginx/nginx.conf /etc/nginx/network_internal.conf /etc/nginx/
RUN mkdir -p /etc/nginx/toplevel.conf.d /etc/nginx/dhparam /etc/nginx/certs /usr/share/nginx/html/errors

COPY --from=upstream /usr/local/bin/forego /usr/local/bin/docker-gen /usr/local/bin/
COPY --from=upstream /app/ /app/
WORKDIR /app/

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
