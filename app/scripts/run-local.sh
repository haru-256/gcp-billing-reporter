#!/usr/bin/env bash

set -euo pipefail

PORT="${PORT:-9999}"
TARGET="${TARGET:-main}"
SIGNATURE_TYPE="${SIGNATURE_TYPE:-cloudevent}"

SERVER_PID=""

cleanup() {
  if [[ -n "${SERVER_PID}" ]] && kill -0 "${SERVER_PID}" 2>/dev/null; then
    echo "Stopping functions-framework: pid=${SERVER_PID}"
    kill "${SERVER_PID}" 2>/dev/null || true
    wait "${SERVER_PID}" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

echo "Starting functions-framework on port ${PORT}..."

uv run functions-framework \
  --target="${TARGET}" \
  --signature-type="${SIGNATURE_TYPE}" \
  --port="${PORT}" &

SERVER_PID="$!"

echo "Waiting for functions-framework to become ready..."

for _ in $(seq 1 30); do
  if nc -z localhost "${PORT}" >/dev/null 2>&1; then
    break
  fi

  if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
    echo "functions-framework exited before becoming ready" >&2
    exit 1
  fi

  sleep 1
done

if ! nc -z localhost "${PORT}" >/dev/null 2>&1; then
  echo "Timed out waiting for localhost:${PORT}" >&2
  exit 1
fi

echo "Sending local Pub/Sub CloudEvent..."

curl -fsS -X POST "http://localhost:${PORT}/" \
  -H "Content-Type: application/json" \
  -H "Ce-Id: local-test-1" \
  -H "Ce-Specversion: 1.0" \
  -H "Ce-Type: google.cloud.pubsub.topic.v1.messagePublished" \
  -H "Ce-Source: //pubsub.googleapis.com/projects/local-project/topics/local-topic" \
  -d '{"message":{"data":"e30=","messageId":"1"},"subscription":"local"}'

echo
echo "Done."
