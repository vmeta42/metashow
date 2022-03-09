# Monitor

This projects deploy the prometheus monitor framework. 

# Targets

The monitor target contains:

- Ceph
- K8S
- Openstack
- Zabbix

## Ceph

TODO

## K8S

We deploy the monitor framework base on the following architecture.

![remote-write](img/remote-write2.png)

Each k8s contains promethues+grafana locally, then the admin cluster contains the global prometheus+grafana.  Each k8s promethues upload the metric to OOS(minio), then global grafana select the metric from thanos query which forward the request to thanos-storegateway and local promethues.

### Thanos

it contains minio, query frontend, query and storegateway.

### Kube-prometheus-stack

it contains grafana, prometheus-operator, prometheus.

Links:

1. https://sysrant.com/posts/prometheus-multi-cluster/

## Openstack

TODO

## Zabbix

TODO
