# TubeArchivist

Self-hosted YouTube media archive. Save, organize, and search your YouTube videos.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/tubearchivist)

## Features

- Archive YouTube videos, channels, and playlists
- Full-text search via Elasticsearch
- Automatic metadata extraction
- Tagging and playlist management
- Mobile-responsive web interface
- RSS feed support

## Configuration

| Variable | Description | Default |
|---|---|---|
| `TA_USERNAME` | Initial admin username | `tubearchivist` |
| `TA_PASSWORD` | Initial admin password | *(required)* |
| `ELASTIC_PASSWORD` | Elasticsearch password | *(required)* |
| `TA_HOST` | Public URL of this service | Auto-set from Railway domain |
| `ES_URL` | Elasticsearch connection URL | Auto-set from ES companion |
| `REDIS_CON` | Redis connection URL | Auto-set from Redis companion |
| `TZ` | Timezone | `UTC` |

## Volumes

- `/youtube` — Downloaded media files
- `/cache` — Transcoding cache

## Architecture

This template deploys three services:

1. **tubearchivist** — Main application (Django + Celery + Nginx)
2. **tubearchivist-es** — Elasticsearch for full-text search
3. **tubearchivist-redis** — Redis for task queue and caching

## First Run

1. Set `TA_PASSWORD` and `ELASTIC_PASSWORD` before deploying
2. After deploy, log in with your credentials at the public URL
3. Add YouTube channels or video URLs to start archiving

## License

GPLv3 — [TubeArchivist License](https://github.com/tubearchivist/tubearchivist/blob/master/LICENSE)
