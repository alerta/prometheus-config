#!/bin/sh

curl -sf http://sut:8080/ || (echo "ERROR: no response from web UI" && exit 11)
curl -sf http://sut:8080/api/_ || (echo "ERROR: no response from API endpoint" && exit 12)
curl -sf http://sut:8080/api/alerts?api-key=demo-key || (echo "ERROR: could not query for alerts" && exit 13)