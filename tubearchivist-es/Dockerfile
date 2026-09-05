FROM elasticsearch:8.19.0

USER root

# Fix volume permissions at runtime, remove stale lock
RUN printf '#!/bin/sh\nset -e\nchown -R 1000:1000 /usr/share/elasticsearch/data 2>/dev/null || true\nrm -f /usr/share/elasticsearch/data/.lock 2>/dev/null || true\nexec /usr/local/bin/docker-entrypoint.sh\n' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

ENV ES_JAVA_OPTS="-Xms512m -Xmx512m"
ENV discovery.type=single-node
ENV xpack.security.enabled=true
ENV path.repo=/usr/share/elasticsearch/data/snapshot

EXPOSE 9200

ENTRYPOINT ["/docker-entrypoint.sh"]
