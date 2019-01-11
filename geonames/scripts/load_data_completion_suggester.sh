set -e

curl -XPUT "http://localhost:9201/_ingest/pipeline/suggest" -H 'Content-Type: application/json' -d @geonames_ingest_pipeline.json
curl -XPUT "http://localhost:9202/_ingest/pipeline/suggest" -H 'Content-Type: application/json' -d @geonames_ingest_pipeline.json
curl -XPUT "http://localhost:9203/_ingest/pipeline/suggest" -H 'Content-Type: application/json' -d @geonames_ingest_pipeline.json

curl -XPUT localhost:9201/geonames -H 'Content-Type: application/json' -d @geonames_index.json
curl -XPUT localhost:9202/geonames -H 'Content-Type: application/json' -d @geonames_index.json
curl -XPUT localhost:9203/geonames -H 'Content-Type: application/json' -d @geonames_index.json

esrally --track=geonames --pipeline=benchmark-only --target-host=localhost:9201,localhost:9202,localhost:9203 --include-tasks="index-append"
