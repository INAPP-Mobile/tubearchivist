#!/bin/bash
set -e

if [[ -n "$DJANGO_DEBUG" ]]; then
  LOGLEVEL="DEBUG"
else
  LOGLEVEL="INFO"
fi

# update yt-dlp if needed
if [[ "${TA_AUTO_UPDATE_YTDLP,,}" =~ ^(release|nightly)$ ]]; then
    echo "Updating yt-dlp..."
    preflag=$([[ "${TA_AUTO_UPDATE_YTDLP,,}" == "nightly" ]] && echo "--pre" || echo "")
    python -m pip install --target=/root/.local/bin --upgrade $preflag "yt-dlp[default]" || {
        echo "yt-dlp update failed"
    }
fi

# stop on pending manual migration
python manage.py ta_stop_on_error

# django setup
python manage.py migrate
python manage.py collectstatic --noinput -c

# ta setup
python manage.py ta_envcheck
python manage.py ta_connection
python manage.py ta_startup

# POT token provider self-activation (Railway template).
# TA only reads downloads.pot_provider_url from its ES-backed app config
# (ta_config/_doc/appsettings), never from the environment. Seed it once
# from POT_PROVIDER_URL so fresh installs work without a manual API call.
if [[ -n "$POT_PROVIDER_URL" ]]; then
    ES_AUTH="${ELASTIC_USER:-elastic}:${ELASTIC_PASSWORD}"
    ES_BASE="$ES_URL"
    if cur=$(curl -fsS -u "$ES_AUTH" "$ES_BASE/ta_config/_doc/appsettings" 2>/dev/null); then
        existing=$(printf '%s' "$cur" | python -c 'import json,sys
d=json.load(sys.stdin)
print(d["_source"].get("downloads",{}).get("pot_provider_url") or "")' 2>/dev/null)
        if [[ -z "$existing" ]]; then
            code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -u "$ES_AUTH" \
                -H 'Content-Type: application/json' \
                "$ES_BASE/ta_config/_update/appsettings?refresh=true" \
                -d "{\"doc\":{\"downloads\":{\"pot_provider_url\":\"$POT_PROVIDER_URL\"}}}")
            echo "[pot-seed] set pot_provider_url from POT_PROVIDER_URL env (status $code)"
        else
            echo "[pot-seed] pot_provider_url already set: $existing"
        fi
    else
        echo "[pot-seed] ta_config not readable yet, skipping seed"
    fi
fi

# start all tasks
nginx &
celery -A task.celery worker \
    --loglevel=$LOGLEVEL \
    --concurrency 4 \
    --max-tasks-per-child 5 \
    --max-memory-per-child 150000 &

./beat_auto_spawn.sh &

python backend_start.py