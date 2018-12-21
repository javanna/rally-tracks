#!/bin/bash

set -e

seed=123456789
iters=200

for shards in 1 2 4 8 16 32 64
do
    index="so$shards" 
    ./swap_indices.sh $index 
    for latency in 0 50 100 200 300
    do

        echo "Running ordinary CCS benchmarks with $shards shards and $latency latency"
        esrally --track=so --pipeline=benchmark-only --target-hosts="target_hosts.json" --client-options="client_options.json" --challenge=ccs-ordinary-refined --include-tasks="update-latency,match-all-random-sort-size-10" --track-params="index:'$index',latency:$latency,iters:$iters,seed:$seed" --user-tag="shards:$shards,latency:$latency,ccs:ordinary,query:match-all-random-sort-size-10" --telemetry=node-stats
        esrally --track=so --pipeline=benchmark-only --target-hosts="target_hosts.json" --client-options="client_options.json" --challenge=ccs-ordinary-refined --include-tasks="match-all-random-sort-size-100" --track-params="index:'$index',latency:$latency,iters:$iters,seed:$seed" --user-tag="shards:$shards,latency:$latency,ccs:ordinary,query:match-all-random-sort-size-100" --telemetry=node-stats
        esrally --track=so --pipeline=benchmark-only --target-hosts="target_hosts.json" --client-options="client_options.json" --challenge=ccs-ordinary-refined --include-tasks="terms-aggs-cache" --track-params="index:'$index',latency:$latency,iters:$iters,seed:$seed" --user-tag="shards:$shards,latency:$latency,ccs:ordinary,query:terms-aggs-cache" --telemetry=node-stats

        echo "Running multi_coord CCS benchmarks with $shards shards and $latency latency"
        esrally --track=so --pipeline=benchmark-only --target-hosts="target_hosts.json" --client-options="client_options.json" --challenge=ccs-multi-coord-refined --include-tasks="match-all-random-sort-size-10" --track-params="index:'$index',latency:$latency,iters:$iters,seed:$seed" --user-tag="shards:$shards,latency:$latency,ccs:multi_coord,query:match-all-random-sort-size-10" --telemetry=node-stats
        esrally --track=so --pipeline=benchmark-only --target-hosts="target_hosts.json" --client-options="client_options.json" --challenge=ccs-multi-coord-refined --include-tasks="match-all-random-sort-size-100" --track-params="index:'$index',latency:$latency,iters:$iters,seed:$seed" --user-tag="shards:$shards,latency:$latency,ccs:multi_coord,query:match-all-random-sort-size-100" --telemetry=node-stats
        esrally --track=so --pipeline=benchmark-only --target-hosts="target_hosts.json" --client-options="client_options.json" --challenge=ccs-multi-coord-refined --include-tasks="terms-aggs-cache" --track-params="index:'$index',latency:$latency,iters:$iters,seed:$seed" --user-tag="shards:$shards,latency:$latency,ccs:multi_coord,query:terms-aggs-cache" --telemetry=node-stats
    
    done
done
