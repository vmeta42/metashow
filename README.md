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

1. Each k8s contains promethues+grafana locally, for example: dev k8s、b28 k8s、m6 k8s.
2. Admin cluster contains the global prometheus+grafana.  The global prometheus contains metric for openstack、ceph、zabbix.
3. Each k8s promethues thanos sidecar uploads the metric to OOS(minio)
4. Global grafana select the metric from thanos query which forward the request to thanos-storegateway、each k8s sidecar and local promethues.

### Thanos

it contains minio, query frontend, query and storegateway.

### Kube-prometheus-stack

it contains grafana, prometheus-operator, prometheus.

### Links:

1. https://sysrant.com/posts/prometheus-multi-cluster/

## Openstack

TODO

## Zabbix

TODO
