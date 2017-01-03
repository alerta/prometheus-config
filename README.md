Prometheus Config for Alerta
============================

Consolidate alerts from [Prometheus](http://prometheus.io/) and other
tools (like Nagios or Zabbix) into a single "at-a-glance" console.

Transform this ...

![alertmanager](/docs/images/prometheus-alertmanager.png?raw=true)

Into this ...

![alerta](/docs/images/prometheus-alerta.png?raw=true)

Installation
------------

Install the following:

  * Prometheus
  * Prometheus Alertmanager
  * Alerta

Configuration - Alertmanager
----------------------------

This integration takes advantage of configurable webhooks available with
Prometheus [Alertmanager](http://prometheus.io/docs/alerting/alertmanager/).

Support for Prometheus is built-in to Alerta so no special configuration
is required other than to ensure the webhook URL is correct in the
`alertmanager.yml` config file.

**Example receivers section**

```
receivers:
- name: "alerta"
  webhook_configs:
  - url: 'http://localhost:8080/webhooks/prometheus'
    send_resolved: true
```

**Note:** If the [Docker container for Alerta](https://hub.docker.com/r/alerta/alerta-web/)
is used then the webhook URL will use a host and port specific to
your environment and the URL path will be `/api/webhooks/prometheus`.

**Example receivers section (if authentication enabled)**

If Alerta is configured to enforce authentication then the webhook
URL needs to include an API key as a paramter like so:

```
receivers:
- name: "alerta"
  webhook_configs:
  - url: 'http://localhost:8080/webhooks/prometheus?api-key=QBPALlsFSkokm-XiOSupkbpK4SJdFBtStfrOjcdG'
    send_resolved: true
```

Configuration - Rules
---------------------

Alertmanager rules define thresholds at which alerts should be triggered.
The following table illustrates how Prometheus notification data is
used to populate Alerta attributes in those triggered alerts:

| **Prometheus**         | Type          | **Alerta**   |
-------------------------|---------------|---------------
| instance      (*)      | internal      | resource     |
| alertname     (*)      | internal      | event        |
| environment            | label         | environment  |
| severity               | label         | severity (+) |
| correlate              | label         | correlate    |
| service                | label         | service      |
| job           (*)      | internal      | group        |
| value                  | label         | value        |
| description or summary | annotation    | text         |
| unassigned labels      | label         | tags         |
| unassigned annotations | annotation    | attributes   |
| monitor                | label         | origin       |
| externalURL   (*)      | internal      | externalUrl  |
| generatorlURL (*)      | internal      | moreInfo     |
| "prometheusAlert"      | n/a           | type         |
| raw notification       | n/a           | rawData      |

Prometheus labels marked with a star (*) are built-in and assignment to
Alerta attributes happens automatically. All other labels or annotations
are user-defined and completely optional as they have sensible defaults.

Much more value can be obtained from the Alerta console if reasonable
values are assigned where possible. This is demonstrated in the example
alert rules below which get increasingly informative.

Run
---

Use the provided `prometheus.yml`, `rules.conf` and `alertmanager.yml`
files to start with and run `prometheus` and `alertmanager` as follows:

    $ ./prometheus -config.file=prometheus.yml -alertmanager.url=http://localhost:9093
    $ ./alertmanager -config.file=alertmanager.yml

Prometheus Web => http://localhost:9090

Alertmanager Web => http://localhost:9093

Examples
--------

*Basic Example*

The example rule below is the absolute minimum required to trigger a
"warning" alert and a corresponding "normal" alert for forwarding to Alerta.

```
ALERT MinimalAlert
  IF metric > 0
  LABELS {}
```

*Simple Example*

```
ALERT SimpleAlert
  IF metric > 0
  LABELS {
    service = "Web",
    severity = "major",
    value = "{{$value}}"
  }
  ANNOTATIONS {
    description = "simple alert triggered at {{$value}}"
  }
```

*Complete Example*

```
global:
  external_labels:
    environment: Production
    service: Prometheus
    monitor: codelab
```

```
ALERT CompleteAlert
  IF metric > 0
  LABELS {
    service = "Web",
    severity = "minor",
    value = "{{$value}}",
  }
  ANNOTATIONS {
    summary = "alert triggered",
    description = "complete alert triggered at {{$value}}",
    runbook = "http://wiki.alerta.io"
  }
```

It is desirable that the `prometheus.yml` and `rules.conf` configuration files conform to an expected format
but it is not mandatory.

Example `prometheus.yml` Global section:

It is possible to set labels that will be used for all alerts that are
sent to Alerta. So if your Prometheus server is only used for Production
or Development or a particular service then you can define these labels
globally so that you don't have to repeat them for every rule.

```
global:
  external_labels:
    environment: Production
    service: Prometheus
    monitor: codelab
```

Metrics
-------

Alerta exposes prometheus metrics natively on `/management/metrics` so
alerts can be generated based on Alerta performance.

[Counter, Gauge and Summary metrics](http://prometheus.io/docs/concepts/metric_types/) are exposed
and all use `alerta` as the application prefix. Metrics are created
lazily, so for example, a summary metric for the number of deleted alerts
will not be present in the metric output if an alert has never been deleted.
Note that counters and summaries are **not** reset when Alerta restarts.

*Example Metrics*

```
# HELP alerta_alerts_total Total number of alerts in the database
# TYPE alerta_alerts_total gauge
alerta_alerts_total 1
# HELP alerta_alerts_rejected Number of rejected alerts
# TYPE alerta_alerts_rejected counter
alerta_alerts_rejected_total 3
# HELP alerta_alerts_duplicate Total time to process number of duplicate alerts
# TYPE alerta_alerts_duplicate summary
alerta_alerts_duplicate_count 339
alerta_alerts_duplicate_sum 1378
# HELP alerta_alerts_received Total time to process number of received alerts
# TYPE alerta_alerts_received summary
alerta_alerts_received_count 20
alerta_alerts_received_sum 201
# HELP alerta_plugins_prereceive Total number of pre-receive plugins
# TYPE alerta_plugins_prereceive summary
alerta_plugins_prereceive_count 390
alerta_plugins_prereceive_sum 10
# HELP alerta_plugins_postreceive Total number of post-receive plugins
# TYPE alerta_plugins_postreceive summary
alerta_plugins_postreceive_count 387
alerta_plugins_postreceive_sum 3
# HELP alerta_alerts_create Total time to process number of new alerts
# TYPE alerta_alerts_create summary
alerta_alerts_create_count 26
alerta_alerts_create_sum 85
# HELP alerta_alerts_queries Total time to process number of alert queries
# TYPE alerta_alerts_queries summary
alerta_alerts_queries_count 57357
alerta_alerts_queries_sum 195402
# HELP alerta_alerts_deleted Total time to process number of deleted alerts
# TYPE alerta_alerts_deleted summary
alerta_alerts_deleted_count 32
alerta_alerts_deleted_sum 59
# HELP alerta_alerts_tagged Total time to tag number of alerts
# TYPE alerta_alerts_tagged summary
alerta_alerts_tagged_count 1
alerta_alerts_tagged_sum 4
# HELP alerta_alerts_untagged Total time to un-tag number of alerts
# TYPE alerta_alerts_untagged summary
alerta_alerts_untagged_count 1
alerta_alerts_untagged_sum 1
# HELP alerta_alerts_status Total time and number of alerts with status changed
# TYPE alerta_alerts_status summary
alerta_alerts_status_count 2
alerta_alerts_status_sum 3
# HELP alerta_alerts_webhook Total time to process number of web hook alerts
# TYPE alerta_alerts_webhook summary
alerta_alerts_webhook_count 344
alerta_alerts_webhook_sum 3081
# HELP alerta_alerts_correlate Total time to process number of correlated alerts
# TYPE alerta_alerts_correlate summary
alerta_alerts_correlate_count 23
alerta_alerts_correlate_sum 69
```


References
----------

* Kubernetes [namespaces](http://kubernetes.io/docs/user-guide/namespaces/)
* Kubernetes [labels](http://kubernetes.io/docs/user-guide/labels/)
* Kubernetes [annotations](http://kubernetes.io/docs/user-guide/annotations/)
* Kubernetes [metadata](https://github.com/kubernetes/kubernetes/blob/master/docs/devel/api-conventions.md#metadata)

License
-------

Copyright (c) 2016 Nick Satterly. Available under the MIT License.
