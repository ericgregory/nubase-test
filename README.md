# Demo: Wasm Native Database API with Couchbase (and Secrets)

This demo is a light adaptation of the demo from the [WasmCon 2024 workshop](https://github.com/vados-cosmonic/wasmcon2024-couchbase-workshop) by [Victor Adossi](https://github.com/vados-cosmonic) and [Laurent Doguin](https://github.com/ldoguin). This version uses secrets and a NATS-based secrets backend when deploying the application. 



```shell
docker-compose up -d
```
```output
[+] Running 4/4
 ✔ Network nubase-test_default                Created                                                                                                                                    0.0s 
 ✔ Container nubase-test-couchbase-1          Started                                                                                                                                    0.1s 
 ✔ Container nubase-test-jaeger-all-in-one-1  Started                                                                                                                                    0.0s 
 ✔ Container nubase-test-couchbase-init-1     Started                                                                                                                                    0.0s
 ``` 
```shell
wash build -p provider-couchbase
```
```output
Built artifact can be found at "/Users/egregory/dev/nubase-test/provider-couchbase/build/wasmcloud-provider-couchbase.par.gz"
```
```shell
wash build -p component-nubase
```
```output
Component built and signed and can be found at "/Users/egregory/dev/nubase-test/component-nubase/build/nubase_s.wasm"
```
```shell
WASMCLOUD_SECRETS_TOPIC=wasmcloud.secrets \
   wash up -d
```
```shell
./start.sh
```
```shell
wash app deploy wadm.yaml
```