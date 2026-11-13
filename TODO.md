# TODO

Open points for the nginx-proxy stack. Each one is discussed and decided
separately before it is implemented.

## Open

Nothing open right now.

## Done / decided

- 2026-11-13: checked the htpasswd bypass found on omac.rpreview.ro (`/index.php` open without a
  password). The proxy is not affected: nginx-proxy puts `auth_basic` in the only `location /` of the
  site, so phpMyAdmin / Mailpit / RabbitMQ ask for it on every path (`conf/phpmyadmin-port.conf.sample`
  has it at `server` level). The cause was m2docker's `default.conf` (auth inside `location /` only),
  fixed there.
- 2026-10-30: optional, uncommitted `compose.override.yaml` (loaded by `bin/docker-compose`) for
  proxy network aliases, so containers reach `.test` sites through the proxy (SSR). Aliases added by hand
  with `docker network connect --alias` were lost whenever the proxy was recreated.
- 2026-10-23: image versions are pinned in docker-compose.yml, `.env` only overrides them.
  acme / self-signed companions and phpMyAdmin stay on `latest`, RabbitMQ stays on 4.1 for
  the older projects, OpenSearch stays on 3.9.0 (projects are updated to it).
- 2026-10-23: Mailcatcher replaced by Mailpit (`mailcatcher` network alias kept).
- 2026-10-23: fixed `bin/start` (dropped its first argument) and `bin/setup` (substring match
  of networks and /etc/hosts entries); removed the unused, broken `bin/docker-status`.
- htpasswd on phpMyAdmin / RabbitMQ / Mailpit is enough, no IP allow list
  (decided 2026-10-23). RabbitMQ 5672 stays published.
