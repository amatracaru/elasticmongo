#!/bin/bash
echo "Waiting for Mongo startup.."
until curl http://mongo:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1; do
  printf '.'
  sleep 1
done

echo curl http://mongo:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1
echo "Mongo Started"

mongo --host mongo:27017 <<EOF
    rs.initiate();
EOF

echo "Waiting for Elasticsearch startup.."
until curl http://elasticsearch:9200/_cluster/health?pretty | grep status | egrep "(green|yellow)" 2>&1; do
  printf '.'
  sleep 2
done

echo "Elasticsearch Started"
echo "Creating index"
curl -XPUT http://elasticsearch:9200/crm -d '{
  "settings": {
    "analysis": {
    "filter": {
        "ngram_filter": {
            "type":    "nGram",
            "min_gram": 2,
            "max_gram": 20
        },
        "edge_ngram_filter": {
            "type":    "edgeNGram",
            "min_gram": 2,
            "max_gram": 20
        }
      },
      "analyzer": {
        "ngram_analyzer": {
          "type":      "custom",
          "tokenizer": "keyword",
          "filter":    [ "lowercase", "asciifolding", "ngram_filter" ]
        },
        "edge_ngram_analyzer": {
          "type":      "custom",
          "tokenizer": "keyword",
          "filter":    [ "lowercase", "asciifolding", "edge_ngram_filter" ]
        },
        "search_analyzer": {
            "type": "custom",
            "tokenizer": "keyword",
            "filter": ["lowercase", "asciifolding"]
        }
      }
    }
  },
  "mappings": {
    "Accounts": {
      "dynamic": "false",
      "properties": {
        "AccountCodeLowercase": {
          "type": "keyword",
          "fields": {
            "contains": {
              "type": "text",
              "analyzer":  "ngram_analyzer",
              "search_analyzer": "search_analyzer"
            },
            "startswith": {
              "type": "text",
              "analyzer":  "edge_ngram_analyzer",
              "search_analyzer": "search_analyzer"
            }
          }
        },
        "AccountELEList": {
          "type": "nested",
          "properties": {
            "CustomerStatus": {
              "type": "short"
            },
            "EurofinsLegalEntityCode": {
                "type": "keyword",
                "fields": {
                    "contains": {
                    "type": "text",
                    "analyzer":  "ngram_analyzer",
                    "search_analyzer": "search_analyzer"
                    },
                    "startswith": {
                    "type": "text",
                    "analyzer":  "edge_ngram_analyzer",
                    "search_analyzer": "search_analyzer"
                    }
                }
            },
            "HasOperationalRelationship": {
              "type": "boolean"
            },
            "LabSites": {
              "type": "nested",
              "properties": {
                "LabSiteCode": {
                  "type": "keyword"
                }
              }
            }
          }
        },
        "AccountState": {
          "type": "short"
        },
        "AddressList": {
          "type": "nested",
          "properties": {
            "AddressCode": {
              "type": "keyword"
            },
            "AddressState": {
              "type": "short"
            },
            "AddressType": {
              "type": "short"
            }
          }
        },
        "ContactList": {
          "type": "nested",
          "properties": {
            "AddressList": {
              "type": "nested",
              "properties": {
                "AddressCode": {
                  "type": "keyword"
                },
                "AddressState": {
                  "type": "short"
                },
                "IsPrimary": {
                  "type": "boolean"
                }
              }
            },
            "ContactCode": {
              "type": "keyword"
            },
            "ContactState": {
              "type": "short"
            },
            "FirstName": {
                "type": "keyword",
                "fields": {
                    "contains": {
                    "type": "text",
                    "analyzer":  "ngram_analyzer",
                    "search_analyzer": "search_analyzer"
                    },
                    "startswith": {
                    "type": "text",
                    "analyzer":  "edge_ngram_analyzer",
                    "search_analyzer": "search_analyzer"
                    }
                }
            },
            "LastName": {
                "type": "keyword",
                "fields": {
                    "contains": {
                    "type": "text",
                    "analyzer":  "ngram_analyzer",
                    "search_analyzer": "search_analyzer"
                    },
                    "startswith": {
                    "type": "text",
                    "analyzer":  "edge_ngram_analyzer",
                    "search_analyzer": "search_analyzer"
                    }
                }
            }
          }
        },
        "IntercoEurofinsBusinessUnitCode": {
            "type": "keyword",
            "fields": {
                "contains": {
                "type": "text",
                "analyzer":  "ngram_analyzer",
                "search_analyzer": "search_analyzer"
                },
                "startswith": {
                "type": "text",
                "analyzer":  "edge_ngram_analyzer",
                "search_analyzer": "search_analyzer"
                }
            }
        },
        "InternalName": {
            "type": "keyword",
            "fields": {
                "contains": {
                "type": "text",
                "analyzer":  "ngram_analyzer",
                "search_analyzer": "search_analyzer"
                },
                "startswith": {
                "type": "text",
                "analyzer":  "edge_ngram_analyzer",
                "search_analyzer": "search_analyzer"
                }
            }
        },
        "IsTradeAccount": {
          "type": "boolean"
        },
        "ParentAccountCode": {
          "type": "keyword"
        },
        "RegisteredCity": {
            "type": "keyword",
            "fields": {
                "contains": {
                "type": "text",
                "analyzer":  "ngram_analyzer",
                "search_analyzer": "search_analyzer"
                },
                "startswith": {
                "type": "text",
                "analyzer":  "edge_ngram_analyzer",
                "search_analyzer": "search_analyzer"
                }
            }
        },
        "RegisteredName": {
            "type": "keyword",
            "fields": {
                "contains": {
                "type": "text",
                "analyzer":  "ngram_analyzer",
                "search_analyzer": "search_analyzer"
                },
                "startswith": {
                "type": "text",
                "analyzer":  "edge_ngram_analyzer",
                "search_analyzer": "search_analyzer"
                }
            }
        },
        "RootParentAccountCode": {
          "type": "keyword"
        },
        "SalesScope": {
          "type": "keyword"
        }
      }
    },
    "SaleScopes": {
      "properties": {
        "EurofinsLegalEntities": {
          "type": "keyword"
        }
      }
    }
  }
}'