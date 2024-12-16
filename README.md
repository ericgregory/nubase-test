# NuBase: Wasm Native Database API with Couchbase (and Secrets)

This demo is a light adaptation of the demo from the [WasmCon 2024 workshop](https://github.com/vados-cosmonic/wasmcon2024-couchbase-workshop) by [Victor Adossi](https://github.com/vados-cosmonic) and [Laurent Doguin](https://github.com/ldoguin). This version uses secrets and a NATS-based secrets backend when deploying the application. 

# ✨ NuBase

NuBase is a WebAssembly-native database, exposed via HTTP.

Importantly, this [WebAssembly Component][wasm-components] `import`s the `wasmcoud:couchbase/documents`
interface (see [related WIT](../wit/nubase.wit)), and makes that functionality available via HTTP
by exporting the [WASI][wasi] standard [`wasi:http/incoming-handler`][wasi-http].

[couchbase]: https://couchbase.com
[wit]: https://github.com/WebAssembly/component-model/blob/main/design/mvp/WIT.md
[wasi-http]: https://github.com/WebAssembly/wasi-http
[wasm-components]: https://component-model.bytecodealliance.org/
[wasi]: https://wasi.dev

### 📚 NuBase HTTP API

NuBase's API is simple, maximizing for developer UX, exposing simple
document-level operations -- a "baby's first [Couchbase][couchbase] API", making use of the full
power of Couchbase underneath:

| API endpoint                        | Description                                     |
|-------------------------------------|-------------------------------------------------|
| `GET /api/v1/_status`               | Basic status endpoint (returns "ok") if present |
| `GET /api/v1/documents`             | Get all documents (paginated)                   |
| `GET /api/v1/documents/:id`         | Get a single document                           |
| `PUT /api/v1/documents`             | Insert a single document                        |
| `POST /api/v1/documents`            | Insert a single document                        |
| `POST /api/v1/batch/insert`         | Insert multiple documents                       |
| `DELETE /api/v1/documents/:id`      | Delete a single existing document               |
| `POST /api/v1/documents/:id/upsert` | Upsert a single document                        |
| `POST /api/v1/batch/upsert`         | Perform multiple upserts                        |

**The implementation for this component is partially finished, but you'll have to write the rest!**.

## 👟 Quickstart

### Setup

For this example, you'll need:

- The [wasmcloud Shell (`wash`)](https://wasmcloud.com/docs/installation) CLI 0.37.0+ to build WebAssembly components and deploy to local wasmCloud.
- The Go language toolchain, consisting of [Go](https://go.dev/doc/install) 1.23.0+, [TinyGo](https://tinygo.org/getting-started/install/) 0.33.0+, and [`wasm-tools`](https://github.com/bytecodealliance/wasm-tools) 1.219+ (see the quickstart for [toolchain installation instructions](/docs/tour/hello-world#choose-your-language))
- [`docker`](https://docs.docker.com) for running Couchbase.
- The [`secrets-nats-kv`](https://github.com/wasmCloud/wasmCloud/tree/main/crates/secrets-nats-kv) CLI (currently requires the [Rust toolchain](https://www.rust-lang.org/tools/install))

### Start Couchbase and wasmCloud locally

Clone the [wasmcloud-contrib](https://github.com/wasmCloud/wasmCloud-contrib) repository and navigate to this directory (`nubase`). Then use the Docker Compose file in this directory to start Couchbase: 

```bash
docker-compose up -d
```

This demo application consists of:

* The NuBase component (built locally)
* The Couchbase provider (built locally)
* An HTTP server provider (fetched from GitHub Packages)

Let's go ahead and build the Couchbase provider:

```shell
wash build -p provider-couchbase
```

Now we'll build the NuBase component:

```shell
wash build -p component-nubase
```

Start a local wasmCloud environment (using the `-d`/`--detached` flag to run in the background) and set the NATS topic that our environment will use for secrets:

```shell
WASMCLOUD_SECRETS_TOPIC=wasmcloud.secrets \
   wash up -d
```

### Deploy the application

Now we'll run a shell script that will:

* Generate encryption keys 
* Run our NATS KV secrets backend
* Put the password in the NATS KV secrets backend 

As always with a shell script, take a look at the script and make sure you're comfortable with what's going on before running it.

```shell
./start.sh
```

Deploy the application:

```shell
wash app deploy wadm.yaml
```

Check whether the application has been successfully deployed with `wash app list`.

Once the app reaches `Deployed` status, we can test it out.

## Local usage guide

To check the status of the application:

```console
curl localhost:8080/api/v1/_status
```

Let's dive into some more usage patterns.

### Add a document

Once you're sure it's running, you can send JSON payloads over:

```console
curl localhost:8080/api/v1/documents/1 --data '{"example": "document"}'
```

### Retrieve a document

You should get back the ID of the document you inserted -- you can feed that ID into another CURL to retrieve the document we just wrote (by ID):

```console
curl localhost:8080/api/v1/documents/1
```

### Upsert a document

We can insert or update-with-[JSON-patch][json-patch] a document:

```console
curl localhost:8080/api/v1/documents/1/upsert --data-binary @- <<EOF
{
  "docId": "1",
  "patches": [
    { "op": "replace", "path": "/example", "value": "replaced" }
  ],
  "insert": {
    "example": "document"
  }
}
EOF
```

[json-patch]: https://jsonpatch.com/

### Batch insert a document

We can insert multiple documents at the same time:

```console
curl localhost:8080/api/v1/batch/insert --data-binary @- <<EOF
{
  "docs": [
    {
      "docId": "1",
      "doc": {"example": "document"}
    },
    {
      "docId": "2",
      "doc": {"example": "document-2"}
    }
  ]
}
EOF
```

### Delete an existing document

You can delete the document you just created as well:

```console
curl -X DELETE localhost:8080/api/v1/documents/1
```

### Clean up

When you're done with the demo, you can delete the application from your local wasmCloud:

```shell
wash app delete nubase
```
To stop the wasmCloud instance:

```shell
wash down
```


[wasmcloud-docs-provider]: https://wasmcloud.com/docs/concepts/providers
[wash-dev]: https://wasmcloud.com/docs/cli/#wash-dev