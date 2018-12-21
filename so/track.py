import random

class HighlightingRandomSort:
    def __init__(self, track, params, **kwargs):
        self._random = random.Random()
        self._random.seed(a=params.get("seed"))
        self._index_name = params.get("index")
        self._from = params.get("from", 0)
        self._size = params.get("size", 100)

    def partition(self, partition_index, total_partitions):
        return self

    def size(self):
        return 1

    def params(self):
        # you must provide all parameters that the runner expects
        return {
            "body": {
              "query": {
                "function_score": {
                  "query": {
                    "multi_match": {
                      "query": "java xml",
                      "fields": ["title", "body"]
                    }
                  },
                  "functions": [
                    {
                      "random_score": {
                        "seed": self._random.randint(1, 1000000)
                      }
                    }
                  ],
                  "boost_mode": "replace"
                }
              },
              "highlight": {
                "fields": {
                  "title" : {},
                  "body" : {}
                }
              },
              "from": self._from,
              "size": self._size
            },
            "index": self._index_name,
            "request-params" : {
              "max_concurrent_shard_requests" : 16,
              "pre_filter_shard_size" : 512
            }
        }

class MatchAllRandomSort:
    def __init__(self, track, params, **kwargs):
        self._random = random.Random()
        self._random.seed(a=params.get("seed"))
        self._index_name = params.get("index")
        self._from = params.get("from", 0)
        self._size = params.get("size", 100)

    def partition(self, partition_index, total_partitions):
        return self

    def size(self):
        return 1

    def params(self):
        return {
            "body": {
              "query": {
                "function_score": {
                  "query": {
                    "match_all": {}  
                  },
                  "functions": [
                    { 
                      "random_score": {
                        "seed": self._random.randint(1, 1000000)
                      }
                    }
                  ],
                  "boost_mode": "replace"
                }
              },
              "from": self._from,
              "size": self._size
            },
            "index": self._index_name,
            "request-params" : {
              "max_concurrent_shard_requests" : 16,
              "pre_filter_shard_size" : 512
            }
        }

class PrepareIndices:
    multi_cluster = True

    def __call__(self, es, params):
        for key, client in es.items():
          if key != 'default':
            client.indices.close(index='so*')

        index_name = params.get("index")
        for key, client in es.items():
          if key != 'default':
            client.indices.open(index=index_name)

        for key, client in es.items():
          if key != 'default':
            client.cluster.health(index=index_name, wait_for_status='green')        

    def __repr__(self, *args, **kwargs):
        return "prepare-indices"

class UpdateLatency:
    multi_cluster = True

    def __call__(self, es, params):
        latency = params['latency']
        if latency > 0:
          body = {
            "transient" : {
              "transport.tcp.response_latency" : "%sms" % latency
            }
          }
        else :
          body = {
            "transient" : {
              "transport.tcp.response_latency" : None
            }
          }

        for key, client in es.items():
          if key != 'default':
            client.cluster.put_settings(body=body)

    def __repr__(self, *args, **kwargs):
        return "update-latency"


def ccs_multi_coord(es, params):
    request_params = params.get("request-params", {})
    if "cache" in params:
        request_params["request_cache"] = str(params["cache"]).lower()
    index_name = params["index"]
    es.transport.perform_request("GET", "/" + index_name + "/_ccs", params=request_params, body=params["body"])
    return 1, "ops"

def register(registry):
    registry.register_param_source("match-all-random-sort", MatchAllRandomSort)
    registry.register_param_source("highlighting-random-sort", HighlightingRandomSort)
    registry.register_runner("ccs_multi_coord", ccs_multi_coord)
    registry.register_runner("prepare-indices", PrepareIndices())
    registry.register_runner("update-latency", UpdateLatency())

