Prometheus Config for Alerta
============================

Consolidate alerts from [Prometheus](http://prometheus.io/) and other tools (like Nagios or Zabbix) into a single "at-a-glance" console.

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

Configuration
-------------

This integration takes advantage of configurable webhooks available with Prometheus [Alertmanager](http://prometheus.io/docs/alerting/alertmanager/).

Support for Prometheus is built-in to Alerta so no special configuration is required.

The following table illustrates how Prometheus notification data is used to populate Alerta attributes:

| **Prometheus**         | Type          | **Alerta**   |
-------------------------|---------------|---------------
| instance      (*)      | internal      | resource     |
| alertname     (*)      | internal      | event        |
| environment            | label         | environment  |
| severity               | label         | severity (+) |
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
| customer               | label         | customer     |

Prometheus labels marked with a star (*) are built-in and assignment to Alerta attributes happens automatically. All other labels or annotations are user-defined and completely optional as they have sensible defaults.

Much more value can be obtained from the Alerta console if reasonable values are assigned where possible. This is demonstrated in the example alert rules below which get increasingly informative.

Run
---

Run `prometheus` with Alertmanager config pointing to Apache:

    $ ./prometheus -config.file=prometheus.yml -alertmanager.url=http://localhost:9093

Examples
--------

*Basic Example*

The example rule below is the absolute minimum required to trigger a "warning" alert and a corresponding "normal" alert for forwarding to Alerta.

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
    environment: "Production"
    service: "Prometheus"
    region: "eu-west-1"
```

```
ALERT CompleteAlert
  IF metric > 0
  LABELS {
    service = "Web",
    severity = "minor",
    group = "Apache",
    value = "{{$value}}",
  }
  ANNOTATIONS {
    summary = "alert triggered",
    description = "complete alert triggered at {{$value}}",
    runbook = "http://wiki.alerta.io"
  }
```

It is desirable that the `prometheus.yml` and `rules.conf` configuration files conform to an expected format but it is not mandatory.

Example `prometheus.yml` Global section:

It is possible to set labels that will be used for all alerts that are sent to Alerta. So if your Prometheus server is only used for Production or Development or a particular service then you can define these labels globally so that you don't have to repeat them for every rule.

```
global:
  external_labels:
    environment: 'Production'
    service: 'Prometheus'
    zone: 'eu-west-1'
```

References
----------

* Kubernetes [namespaces](https://github.com/kubernetes/kubernetes/blob/master/docs/user-guide/namespaces.md)
* Kubernetes [labels](https://github.com/kubernetes/kubernetes/blob/master/docs/user-guide/labels.md)
* Kubernetes [annotations](https://github.com/kubernetes/kubernetes/blob/master/docs/user-guide/annotations.md)
* Kubernetes [metadata](https://github.com/kubernetes/kubernetes/blob/master/docs/devel/api-conventions.md#metadata)

License
-------

Copyright (c) 2016 Nick Satterly. Available under the MIT License.
