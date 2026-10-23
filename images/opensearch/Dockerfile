# Version comes from docker-compose.yml (OPENSEARCH_VERSION, override in .env)
ARG OPENSEARCH_VERSION=3.9.0
FROM opensearchproject/opensearch:${OPENSEARCH_VERSION}

RUN /usr/share/opensearch/bin/opensearch-plugin install --batch \
  analysis-icu \
  analysis-phonetic
