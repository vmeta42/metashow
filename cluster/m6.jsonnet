local minioSecret=std.extVar("minioSecretKey");
local bindPassword=std.extVar("bindPassword");
local grafanaUser=std.extVar("grafanaUser");
local grafanaPassword=std.extVar("grafanaPassword");
local registry="harborm6.chanty.21vianet.com/library/";
local grafanaHost='grafana-m6.chanty.21vianet.com';
local grafanaUrl='https://'+grafanaHost+'/';
local grafanaKey = |||
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAq4uxIQy8o87S2aMiud/cAS699/vI+76LyJtYfrpgQ93up1PZ
        9uGZqUSJl09c7RNMLnWCJWzOLdZ5x3hsNCZ8omSR/bB7Q05epLEebZoiyrdYSNxI
        rutQVGZzEDZX+MkX8pdt39kh1gddCvV2LKeBOxMDh+QknSdlPUijj6Bj35qnUxQC
        IUnVwehl/gXjvwvx80s4zF26EKjUJ63tzT7efCFfoi67vjhES+0vjj33Mew5reom
        504FqgvoLtGhJ1SJiq3LwEyBO5COlwwgSM3eCr4UfPBPzrynEhJy6aSaMXQ/OAwf
        +hobPsfxTjWM9rgNfkriGJOuhljPpsJPXNG7wwIDAQABAoIBADxsW9u0TM22D/aw
        y46FF00jVa5/dW+W0k26yhT5OOcuyN0PX/rhw+onRf+R6L1oyrCim1DrXkQvA34L
        ILHNzKC2o+WjwAcZF6US7hDU9eRJaENhtAhIwma4H1dajOoIivLb+8uZA54Lwe4W
        P6XC6nYQYHIBHhRsx/AqIdJ5QDSGBTvflUs6SkIJyjFWSeSZdWWtPfNL6xTydBtC
        nLYp7A8ON6Ka9zK60+pLd7YJHgpKcdWHbQh2LeGbK133bIYZ/I8+n0qsNVbsTGpy
        tRSldoCxNN3jJcJW0+kZf1qwrMr7Bb+ViAYvBeq6QAL/NMG7J029xPX7KP+BFUNj
        fjZNdmECgYEA1QjTAMXgljndXrkBrJgcxwUrBGpdXR6wcVE98nxZ45ORoDsn4p1R
        goJc1xZ2H56YxF7KSOYxf/AdrtPpD0vzQaEroS1mzjb5SfzcW5JfiF/mrmomZ0cp
        i1zSz9ySc+H9AaklhgJRlYkZFIZiUoJpHW1M0GPD/h7XySyf2Zdlw90CgYEAziTC
        yfcHmI7JBMAytoVte2iHhcbmKhlu8q1f4SKZGa7puUWM+NOxaEHJGpHEKM4CMJid
        VRyI0qYAWzu8q5zwIlNnelzUC0JSS8ITYicIOly6JfvPabBKVVUER1Akedf2dMHV
        cEXd8mp90IYBAqOvf1agFdWi2ktyEUuufGe81B8CgYEAnbjnx5W5Hl//BmdA1xDT
        lYG9BIrfTtcu2ObGT2ZDgts5oQDLGdtRgqeTpucJU4WvIwvvBiPvmAIlZ8+aqGmZ
        0whJbg5YI+rNjDq6xs1LD4O5HX6XqjUki/qQVba/cy5ojDc4AcxrrKORPwHzf5Tv
        0AqhKVQDwnwBVP9F5epSPL0CgYBuu4h2/N9zr5+DkcqsCNhapjfGQKV6j9btPPx3
        7yHWjgK2pwmmz/BIVK42O37nfGHowNIi2gUVQl6Go3who1fK2IqJTDwLIEEcuM+4
        tcbRsuW7aZxs5WnIlLaLqB0v5jZZWZXRjXY/tbyHurPoOw0Wle3ATNYB9Oz9JW5B
        HWhteQKBgAe2uFKBGlMfg8NTANhykbhZeRfRa9PwyxnusF7ZscFVCVoQ4G1dtYeN
        5+f+zaWwDjft0F5B/lPwuWoTxgQ6wufC3e+UBgqKMHYWLnExs0ucyYA3QG3ZDMS9
        FxCn3UyhjNkVA1CjMp1uFe90qTXbZm2UZ4ofJw34oRVnkh0+JMyw
        -----END RSA PRIVATE KEY-----
      |||;
local grafanaCert = |||
        -----BEGIN CERTIFICATE-----
        MIIDezCCAmOgAwIBAgIJAIVoissb1VN6MA0GCSqGSIb3DQEBCwUAMGQxCzAJBgNV
        BAYTAkNOMQswCQYDVQQIDAJCSjELMAkGA1UEBwwCQkoxETAPBgNVBAoMCDIxdmlh
        bmV0MRcwFQYDVQQLDA5Tb2Z0d2FyZUNlbnRlcjEPMA0GA1UEAwwGcm9vdGNhMCAX
        DTIyMDUyMDA5MDkzN1oYDzIxMjIwNDI2MDkwOTM3WjBlMQswCQYDVQQGEwJDTjEL
        MAkGA1UECAwCQkoxCzAJBgNVBAcMAkJKMREwDwYDVQQKDAgyMXZpYW5ldDEXMBUG
        A1UECwwOU29mdHdhcmVDZW50ZXIxEDAOBgNVBAMMB2dyYWZhbmEwggEiMA0GCSqG
        SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCri7EhDLyjztLZoyK539wBLr33+8j7vovI
        m1h+umBD3e6nU9n24ZmpRImXT1ztE0wudYIlbM4t1nnHeGw0JnyiZJH9sHtDTl6k
        sR5tmiLKt1hI3Eiu61BUZnMQNlf4yRfyl23f2SHWB10K9XYsp4E7EwOH5CSdJ2U9
        SKOPoGPfmqdTFAIhSdXB6GX+BeO/C/HzSzjMXboQqNQnre3NPt58IV+iLru+OERL
        7S+OPfcx7Dmt6ibnTgWqC+gu0aEnVImKrcvATIE7kI6XDCBIzd4KvhR88E/OvKcS
        EnLppJoxdD84DB/6Ghs+x/FONYz2uA1+SuIYk66GWM+mwk9c0bvDAgMBAAGjLTAr
        MCkGA1UdEQQiMCCCHmdyYWZhbmEtbTYuY2hhbnR5LjIxdmlhbmV0LmNvbTANBgkq
        hkiG9w0BAQsFAAOCAQEAIGIzBwLFkXiqjuPxSCCU+k3Eu+DUKS0gkJ1fYpnZrrzv
        MLpM7D+ninq4hlu3KKH5th38x+Y94QKkcDdt/1j37/QM9s0yrb21fEVHnBrb+S88
        H4O/KNLWLIR4BnDCnXO7k+iuHwBuTVcNlUU9tcGBPbmWemVrYxO2RO2rw/eJ9kNH
        Jv3mfWoNqBts/cBxODbsEL2N+jqgdG4uX1lqUaXLNe9btTRZnJTddtJFBGjvyKXG
        fEbBcGb/0Z5CqOf9PmlA3yWmS7VS43O0RCwQ0wjcIJds8IXGNVO34qZCrv1GlpG6
        DfEU+yJo0h68wzd3w9P8VPFBWRxt7H0r/LCMRFQ0mw==
        -----END CERTIFICATE-----
      |||;
local alertmanagerHost='alertmanager-m6.chanty.21vianet.com';
local alertmanagerUrl='https://' + alertmanagerHost;
local alertmanagerCert = |||
        -----BEGIN CERTIFICATE-----
        MIIDhTCCAm2gAwIBAgIJAIVoissb1VN7MA0GCSqGSIb3DQEBCwUAMGQxCzAJBgNV
        BAYTAkNOMQswCQYDVQQIDAJCSjELMAkGA1UEBwwCQkoxETAPBgNVBAoMCDIxdmlh
        bmV0MRcwFQYDVQQLDA5Tb2Z0d2FyZUNlbnRlcjEPMA0GA1UEAwwGcm9vdGNhMCAX
        DTIyMDUyMDA5MTA1MFoYDzIxMjIwNDI2MDkxMDUwWjBqMQswCQYDVQQGEwJDTjEL
        MAkGA1UECAwCQkoxCzAJBgNVBAcMAkJKMREwDwYDVQQKDAgyMXZpYW5ldDEXMBUG
        A1UECwwOU29mdHdhcmVDZW50ZXIxFTATBgNVBAMMDGFsZXJ0bWFuYWdlcjCCASIw
        DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALz31BwmFUyW+YJhkcLAPF7PsKsb
        piaGJNek+1g4Sb87IW0oLTpdFT9cN93VZJsfMZ2/wbyC0HVDe/Z4oybsqI8h+087
        /Pn2BQwtUuMf6Zfuy/yX2qefSFolCc7VkhhvAdCSTaCmzWiizmKp6M25aomKzazJ
        xR4vrSAHXikTdMT/wJAZHv9tTB+wPr+FGYKA3v3zUwpmW0WH9x/aBAwL0rKDMO4M
        adTzM6NtKjf5ZjzRT382NGEyLoIeITW9qVavyxGkiNRhn83yuyMvLudwcR3thkgv
        1V0gCVefBKprPhxk1szmXLUMF253PE+CaiB2ugxRK3f5zXqgu1qqgCJE8+MCAwEA
        AaMyMDAwLgYDVR0RBCcwJYIjYWxlcnRtYW5hZ2VyLW02LmNoYW50eS4yMXZpYW5l
        dC5jb20wDQYJKoZIhvcNAQELBQADggEBAFhTenXi4hQruAl8RIHcXJ6XkTepFOkI
        K8PdBjy9AvTjuz0dbcqA/B7ME3gmUzaUi+ZFmcLcaDJytsSMW69YlCicRfdc92LO
        PaVSjpI93IvSyYU47FgtUT2lP8bb6zElzgT7rh/mXpUGvgN1o2q4beEFPjKFUAg8
        VI4hQB1QSy910BUzSjwglF0JB2Im+mZajeoHN2CpXPxVZH/RskWyTK/pnGaqbZJA
        gRk7yb+WRVQn6bJ3RBeWT3hRK7XxqTXvJVPMV7OTdyqrEstlY7kIlCJMD+MKfXIu
        Ha9r24iTBgilOuY+9lgufx2C6IjP1zI9+5MaQdYgmM4R6RufSgX3JrY=
        -----END CERTIFICATE-----
      |||;
local alertmanagerKey = |||
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAvPfUHCYVTJb5gmGRwsA8Xs+wqxumJoYk16T7WDhJvzshbSgt
        Ol0VP1w33dVkmx8xnb/BvILQdUN79nijJuyojyH7Tzv8+fYFDC1S4x/pl+7L/Jfa
        p59IWiUJztWSGG8B0JJNoKbNaKLOYqnozblqiYrNrMnFHi+tIAdeKRN0xP/AkBke
        /21MH7A+v4UZgoDe/fNTCmZbRYf3H9oEDAvSsoMw7gxp1PMzo20qN/lmPNFPfzY0
        YTIugh4hNb2pVq/LEaSI1GGfzfK7Iy8u53BxHe2GSC/VXSAJV58Eqms+HGTWzOZc
        tQwXbnc8T4JqIHa6DFErd/nNeqC7WqqAIkTz4wIDAQABAoIBADlTERRs9R8j2ZMU
        2Cv1Nxsn9BckLxYWsYx9bwYHJVAOtwgvHPFMlYqABi6Uco2gO+P37OSr5mL8Utml
        JRFEz6mEDIGv2AFYAZX9FdzyrGE7vsPkqR8acc9u1vfY0BX7bth/2W63yy5H3UYO
        9yGZctlAsz4Mg3Cx09oYghcB4PV1fnvzxaKcAejzt+cUQ9Hzt9/Rnkvw89rlKXeA
        zV01WsCfz29K6omBS4D8ChmS/zF5JqntUfWCv+keLYDayMwNq+yhku/yyRdBDAjt
        pDDBv960qUP/uRBqZyxeKOEOsA5xmGhClSlqU2/SZ2u+moZd2m/OM13WN3caOllU
        bMj4A5kCgYEA7OKtbJUJqoCY0fo2AP8URm2bX5k528Va1Jb1YKlNFe7HcmPbCR39
        ysi6JYpsi87kRclOjl5bZaslfA42E4nxUWbyJkBtwPbWX88LtnxrauV0WohAqO9H
        /tCIeBfa60rnvzQEXM22n+5IWESkd8s+sXXp+8aaA/QZtII7+fK2nScCgYEAzDdT
        cVUOpuApbaLWC0KzC9DFlLo071K8CPC6B/2XCgzg0LhjwNiYMhYheQk3tAMsoj72
        unyxtRNpuDYdeTPxr5PIbCoPFAh3DlBesDupA0dj9qalDhBxnOl5WSP42rqzloLP
        +tSNsCFSvHUzpl/F2KOu++2q+EoMyICnnhr+oOUCgYABFoVvYzvZIaASDtEirgk8
        zZISHVULsltZcJwN5pkpCaC24MiHwTCCNuvL8lfPSJL50xPeSYan7+JLMJGFA3Qt
        SIjCLjeS1E9lv0CxhN7Fbepb5BZP8FFnVTPbQVjLDdwEn8uJVZSKJYEFjsMmnbNb
        A0yg0GeyrvNTRenamwfFrwKBgDwtUXlkBx1FkO+tvEU1Mm2Y56Ab/t1HFAHObgNM
        xuU/RkA7FaoOKUsZGmQAQ1nYVZ65zxrFA9jID68owyakF+QVOEonWqoclHizVjO4
        YOWGc/6KvLiYP+JtKkUKRJqvyZvgkEjpuZbdOvQt1TqBnltoYHf8YRUpPPsYbkw4
        yC/BAoGBAOo2E5fMbTWihjMJF2FxE9ZPDW7CkBh/w6161T5CkKu70aIoC0qQc0o8
        XLHqTfArAXmW1gr64bHzliH1ixTXgiNi+aROmaUBj9Bfwe+fUolmwK0M2AucBGjy
        tmsXAdo96jMhw4aizPRLac+kYsHsdzZni/7Ffr7XaImedKQY8nsP
        -----END RSA PRIVATE KEY-----
      |||;

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
          cluster: 'm6-prod',
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

