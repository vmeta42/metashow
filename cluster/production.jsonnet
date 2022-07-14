local minioSecret=std.extVar("minioSecretKey");
local bindPassword=std.extVar("bindPassword");
local grafanaUser=std.extVar("grafanaUser");
local grafanaPassword=std.extVar("grafanaPassword");
local registry="harbor.chanty.21vianet.com/library/";
local grafanaHost='monitor.chanty.21vianet.com';
local grafanaUrl='https://'+grafanaHost+'/';
local grafanaKey = std.extVar("grafanaKey");
local grafanaCert = std.extVar("grafanaCert");
local alertmanagerHost='alertmanager.chanty.21vianet.com';
local alertmanagerUrl='https://' + alertmanagerHost;
local alertmanagerCert = std.extVar("alertmanagerCert");
local alertmanagerKey = std.extVar("alertmanagerKey");

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // Uncomment the following imports to enable its patches
  (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
  (import 'kube-prometheus/addons/all-namespaces.libsonnet') +
  // (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  // (import 'kube-prometheus/addons/node-ports.libsonnet') +
  // (import 'kube-prometheus/addons/static-etcd.libsonnet') +
  // (import 'kube-prometheus/addons/custom-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  (import 'kube-prometheus/platforms/kubeadm.libsonnet') +
  (import 'resource.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
        images: {
          alertmanager: registry + 'alertmanager:v' + $.values.common.versions.alertmanager,
          blackboxExporter: registry + 'blackbox-exporter:v' + $.values.common.versions.blackboxExporter,
          grafana: registry + 'grafana:v' + $.values.common.versions.grafana,
          kubeStateMetrics: registry + 'kube-state-metrics:v' + $.values.common.versions.kubeStateMetrics,
          nodeExporter: registry + 'node-exporter:v' + $.values.common.versions.nodeExporter,
          prometheus: registry + 'prometheus:v' + $.values.common.versions.prometheus,
          prometheusAdapter: registry + 'k8s-prometheus-adapter:v' + $.values.common.versions.prometheusAdapter,
          prometheusOperator: registry + 'prometheus-operator:v' + $.values.common.versions.prometheusOperator,
          prometheusOperatorReloader: registry + 'prometheus-config-reloader:v' + $.values.common.versions.prometheusOperator,
          kubeRbacProxy: registry + 'kube-rbac-proxy:v' + $.values.common.versions.kubeRbacProxy,
          configmapReload: registry + 'configmap-reload:v' + $.values.common.versions.configmapReload,
        },
      },

      ingress+:: {
        alertmanager+: {
          Host: alertmanagerHost,
          Cert: alertmanagerCert,
          Key: alertmanagerKey,
        },
        grafana+:{
          Host: grafanaHost,
          Cert: grafanaCert,
          Key:  grafanaKey,
        },
      },

      prometheus+:: {
        storage: { volumeClaimTemplate: { spec: { storageClassName: 'csi-rbd-sc', resources: { requests: { storage: '40Gi'}}}}},
        thanos: { image: registry + 'thanos:quay-v0.23.1', objectStorageConfig: {key: 'object-store.yaml', name: 'minio'}, version: 'v0.23.1'},
        externalLabels+: {
          cluster: 'production',
          replicas: '2',
        },
        minio: |||
          type: S3
          config:
            bucket: "thanos"
            endpoint: "minitor-minio-api.dev.21vianet.com"
            access_key: "dev-k8s"
            insecure: false
            signature_version2: false
            secret_key: "%s"
            http_config:
              idle_conn_timeout: 1m30s
              response_header_timeout: 2m
              insecure_skip_verify: true
              tls_handshake_timeout: 10s
              expect_continue_timeout: 1s
              max_idle_conns: 100
              max_idle_conns_per_host: 100
              max_conns_per_host: 0
        ||| % minioSecret,
        additionalAlertManagerConfigs: |||
          - api_version: v2
            path_prefix: /
            scheme: https
            tls_config:
              insecure_skip_verify: true
            static_configs:
            - targets:
              - monitor-alertmanager-0.dev.21vianet.com
              - monitor-alertmanager-1.dev.21vianet.com
              - monitor-alertmanager-2.dev.21vianet.com
        |||,
      },
      grafana+:: {
        config+: {
          sections+: {
            server+: {
              root_url: grafanaUrl,
            },
            "auth.ldap"+: {
              enabled: true,
            },
          },
        },
        sc: "csi-cephfs-sc",
        ldap: |||
          verbose_logging = true

          [[servers]]
          host = "21vianet.com"
          port = 3268
          use_ssl = false
          start_tls = false
          ssl_skip_verify = false
          bind_dn = "cn=gitadm,ou=serverusers,ou=21vianet,dc=21vianet,dc=com"
          bind_password = "%s"
          search_filter = "(sAMAccountName=%%s)"
          search_base_dns = ["dc=21vianet,dc=com"]

          [servers.attributes]
          name = "givenName"
          surname = "sn"
          username = "cn"
          member_of = "memberOf"
          email =  "mail"

          [[servers.group_mappings]]
          group_dn = "*"
          org_role = "Viewer"
        ||| % bindPassword,
      },
    },
    // Configure External URL's per application
    alertmanager+:: {
      alertmanager+: {
        spec+: {
          externalUrl: alertmanagerUrl,
        },
      },
    },
    grafana+:: {
      deployment+: {
        spec+: {
          template+: {
            spec+: {
              containers: [
                if c.name == 'grafana' then c {
                  env: [
                    {
                      name: 'GF_SECURITY_ADMIN_USER',
                      value: grafanaUser,
                    },
                    {
                      name: 'GF_SECURITY_ADMIN_PASSWORD',
                      value: grafanaPassword,
                    },
                  ],
                }
                for c in super.containers
              ],
            },
          },
        },
      },
    },
  };

[ kp.kubePrometheus.namespace ] +
[
  kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
] +
[ kp.prometheusOperator.serviceMonitor ] +
[ kp.prometheusOperator.prometheusRule ] +
[ kp.kubePrometheus.prometheusRule ] +
[ kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) ] +
[ kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) ] +
[ kp.grafana[name] for name in std.objectFields(kp.grafana) ] +
[ kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) ] +
[ kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) ] +
[ kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) ] +
[ kp.prometheus[name]
  for name in std.filter((function(name) name != 'thanosSideCarEachService'), std.objectFields(kp.prometheus)) 
] +
[ kp.prometheus.thanosSideCarEachService[name] for name in std.objectFields(kp.prometheus.thanosSideCarEachService) ] +
[ kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) ] +
[ kp.ingress[name] for name in std.objectFields(kp.ingress) ]

