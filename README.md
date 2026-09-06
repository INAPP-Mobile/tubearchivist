# TubeArchivist

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/tubearchivist)

Self-hosted YouTube media archive server — save, organize, and search your
YouTube collection. TubeArchivist downloads videos with metadata, subtitles,
and comments, then indexes everything in Elasticsearch for fast full-text
search, all behind a clean responsive web UI.

## Why Deploy

- **Own your archive** — videos land on your own persistent volume, immune to
  channel deletions, region blocks, or YouTube account loss.
- **Full-text search** — Elasticsearch indexes titles, descriptions, subtitles,
  and comments across your whole library.
- **Automated downloading** — subscribe to channels and playlists; new uploads
  are fetched automatically (or on-demand for single videos).
- **Bot-detection resistant** — ships with a built-in POT-token provider
  companion so yt-dlp downloads don't stall on YouTube's "confirm you're not
  a bot" checks on datacenter IPs.

## Common Use Cases

- Personal YouTube archiving: mirror channels and playlists you follow
- Offline media server: play archived videos from any browser
- Research and content-preservation projects requiring searchable archives
- Automated channel monitoring with scheduled rescans and downloads

## Configuration

| Variable | Description | Default |
|---|---|---|
| `TA_USERNAME` | Initial admin username | `tubearchivist` |
| `TA_PASSWORD` | Initial admin password (auto-generated) | generated |
| `ELASTIC_PASSWORD` | Elasticsearch password (shared with ES service) | generated |
| `TA_HOST` | Public URL of this service | auto-set from Railway domain |
| `ES_URL` | Elasticsearch connection URL | auto-set from ES companion |
| `REDIS_CON` | Redis connection URL | auto-set from Redis companion |
| `POT_PROVIDER_URL` | POT-token provider for yt-dlp | auto-set from POT companion |
| `TA_MEDIA_DIR` | Media directory inside the volume | `/cache/youtube` |
| `TA_AUTO_UPDATE_YTDLP` | Auto-update yt-dlp (`release`/`nightly`/`disabled`) | `release` |
| `TZ` | Timezone (IANA name) | `UTC` |

### Deployment Dependencies

This template deploys **four services**:

1. **tubearchivist** — main app (Django + Celery + nginx), 50GB persistent
   volume at `/cache`
2. **tubearchivist-es** — Elasticsearch 8.19 (search + metadata index), volume
   at `/usr/share/elasticsearch/data`
3. **tubearchivist-redis** — Redis 7.4 (task queue + cache), volume at `/data`
4. **tubearchivist-pot** — POT-token provider (`bgutil-ytdlp-pot-provider`)
   that keeps yt-dlp downloads working from datacenter IPs

Credentials (`TA_PASSWORD`, `ELASTIC_PASSWORD`) are auto-generated per deploy
and shared between the main app and Elasticsearch via template references —
no manual wiring needed.

## About Hosting

All services run as Docker containers on Railway with private networking
(`*.railway.internal` DNS) between them — only the main app is exposed
publicly. Media persists on the main service's 50GB volume at `/cache/youtube`.
First start takes a few minutes while Elasticsearch initializes its index.
Log in with the generated `TA_USERNAME`/`TA_PASSWORD`, then add YouTube
channels or video URLs to start archiving. For heavy archiving, monitor disk
usage in the Railway dashboard and increase the volume size as needed.

## Features

- Archive YouTube videos, channels, and playlists with metadata + subtitles
- Full-text search via Elasticsearch
- Automatic channel/playlist subscription monitoring
- Tagging, download queue, and playlist management
- Mobile-responsive web interface
- Built-in POT-token provider keeps downloads working on datacenter IPs

## License

GPLv3 — [TubeArchivist License](https://github.com/tubearchivist/tubearchivist/blob/master/LICENSE)