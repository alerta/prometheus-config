Prometheus Config for Alerta
============================

This shows how to configure [Prometheus](http://prometheus.io/) to use Alerta as the alert console instead of Prometheus [Alertmanager](http://prometheus.io/docs/alerting/alertmanager/).

Installation
------------

Install the following:

  * Prometheus (without `alertmanager`)
  * Alerta
  * Apache web server
  
Configuration
-------------

Alerta
------

Support for Prometheus is built-in to Alerta so no special Alerta configuration is required.

Reverse Proxy
-------------

It is required to run Apache* as a reverse proxy to map `/api/v1/alerts` to `/webhooks/prometheus`.

The required Apache config is very simple. Apache is configured to listen on the same port a Alertmanager would be and reverse proxies the notification endpoint to Alerta.

```
Listen 9093
<VirtualHost *:9093>
     ProxyPass /api/v1/alerts http://localhost:8080/webhooks/prometheus
</VirtualHost>
```

Prometheus
----------

The following table illustrates how Prometheus notification data is used to populate Alerta attributes:

| **Prometheus**         | Type          | **Alerta**   |
-------------------------|---------------|---------------
| instance      (*)      | internal      | resource     |
| alertname     (*)      | internal      | event        |
| environment            | label         | environment  |
| severity               | label         | severity     |
| correlate              | label         | correlate    |
| service                | label         | service      |
| group                  | label         | group        |
| value                  | label         | value        |
| description or summary | annotation    | text         |
| unassigned labels      | label         | tags         |
| unassigned annotations | annotation    | attributes   |
| job           (*)      | internal      | origin       |
| generatorlURL (*)      | internal      | moreInfo     |
| "prometheusAlert"      | n/a           | type         |
| raw notification       | n/a           | rawData      |

Prometheus labels marked with a star (*) are built-in and assignment to Alerta attributes happens automatically. All other labels or annotations are user-defined and completely optional as they have sensible defaults.

Much more value can be obtained from the Alerta console if reasonable values are assigned where possible. This is demonstrated in the example alert rules below which get increasingly informative.

Basic Example
~~~~~~~~~~~~~

The example rule below is the absolute minimum required to trigger an alert and a corresponding "clear" alert for forwarding to Alerta.

```
ALERT MinimalAlert
  IF metric > 0
  LABELS {}

ALERT MinimalAlert
  IF metric == 0
  LABELS {
    severity = "normal"
  }
```

Simple Example

```
ALERT SystemStart
  IF round(node_time - process_start_time_seconds) < 7200
  LABELS {
    service = "Platform",
    severity = "informational",
    value = "{{humanizeDuration $value}}"
  }
  ANNOTATIONS {
    description = "System started {{humanizeDuration $value}} ago."
  }
```

Full Example

```
global:
  external_labels:
    environment: "Production"
    service: "Prometheus"
    region: "eu-west-1"
```

```
ALERT HttpRequestsHigh
  IF round(rate(collectd_apache_apache_requests[1m])*60) > 12
  LABELS {
    service = "Web",
    severity = "major",
    group = "Apache",
    value = "{{$value}} req/s",
    correlate = "HttpRequestsOk",
    https = "True"
  }
  ANNOTATIONS {
    description = "Apache request rate of {{$value}} requests/sec is above threshold of 12"
  }

ALERT HttpRequestsOk
  IF round(rate(collectd_apache_apache_requests[1m])*60) < 10
  LABELS {
    service = "Web",
    severity = "normal",
    group = "Apache",
    value = "{{$value}} req/s",
    correlate = "HttpRequestsHigh",
    https = "True"
  }
  ANNOTATIONS {
    description = "Apache request rate of {{$value}} requests/sec is below threshold of 10"
  }
```

It is desirable that the `prometheus.yml` and `rules.yml` configuration files conform to an expected format but it is not mandatory.

Example `prometheus.yml` Global section:

It is possible to set labels that will be used for all alerts that are sent to Alerta. So if your Prometheus server is only used for Production or Development or a particular service then you can define these labels globally so that you don't have to repeat them for every rule.

```
global:
  external_labels:
    environment: 'Production'
    service: 'Prometheus'
    zone: 'eu-west-1'
```




Run `prometheus` with alertmanager config pointing to Apache:

    $ ./prometheus -config.file=prometheus.yml -alertmanager.url=http://alerta.example.com:9093

Apache will then reverse proxy the HTTP requests to Alerta on the correct URL.

* Note: It is assumed Apache (or any other web server) is already being used to serve Alerta as a WSGI application.


Example Prometheus Alert



Example Alerta


License
-------

Copyright (c) 2016 Nick Satterly. Available under the MIT License.