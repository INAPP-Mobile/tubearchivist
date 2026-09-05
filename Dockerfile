FROM bbilly1/tubearchivist:v0.5.12

USER root

# Override upstream nginx to map /youtube/ to /cache/youtube/
# (Railway allows only one volume; we keep /cache and nest media under it)
COPY docker_assets/nginx.conf /etc/nginx/sites-available/default

# Fix volume permissions at runtime, then hand off to upstream entrypoint
RUN printf '#!/bin/sh\nset -e\nchown -R 1000:1000 /cache /app 2>/dev/null || true\nmkdir -p /cache/youtube /cache/videos /cache/channels /cache/playlists /cache/download\nexec /bin/tini -- ./run.sh\n' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

ENV TA_BACKEND_PORT=8080 \
    HOST_UID=1000 \
    HOST_GID=1000 \
    TZ=UTC

HEALTHCHECK --interval=2m --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8000/api/health/ || exit 1

EXPOSE 8000

ENTRYPOINT ["/docker-entrypoint.sh"]
