echo "Closing indices"

curl -XPOST localhost:9201/so*/_close?pretty
curl -XPOST localhost:9202/so*/_close?pretty
curl -XPOST localhost:9203/so*/_close?pretty

echo "Opening indices $1"

curl -XPOST localhost:9201/$1/_open?pretty
curl -XPOST localhost:9202/$1/_open?pretty
curl -XPOST localhost:9203/$1/_open?pretty

echo "Waiting for green"

curl "localhost:9201/_cluster/health/$1?wait_for_status=green&pretty"
curl "localhost:9202/_cluster/health/$1?wait_for_status=green&pretty"
curl "localhost:9203/_cluster/health/$1?wait_for_status=green&pretty"
