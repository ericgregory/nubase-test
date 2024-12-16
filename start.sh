#!/bin/bash

# Set secrets topic and start local wasmCloud environment in detached mode
# WASMCLOUD_SECRETS_TOPIC=wasmcloud.secrets \
#    wash up -d

# Generate encryption keys and run the backend
export ENCRYPTION_XKEY_SEED=$(wash keys gen curve -o json | jq -r '.seed')
export TRANSIT_XKEY_SEED=$(wash keys gen curve -o json | jq -r '.seed')
secrets-nats-kv run &
# Put the password in the NATS KV secrets backend
provider_key=$(wash inspect ./provider-couchbase/build/wasmcloud-provider-couchbase.par.gz -o json | jq -r '.service')
secrets-nats-kv put couchbase_password --string password
secrets-nats-kv add-mapping $provider_key --secret couchbase_password
