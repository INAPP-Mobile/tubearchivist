FROM redis:7.4

RUN apt-get update && apt-get install -y tini && rm -rf /var/lib/apt/lists/*

USER root

RUN printf '#!/bin/sh\nset -e\nchown -R redis:redis /data 2>/dev/null || true\nexec /usr/bin/tini -- /usr/local/bin/docker-entrypoint.sh "$@"\n' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

EXPOSE 6379

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["redis-server", "--appendonly", "yes", "--save", "60", "1000"]
