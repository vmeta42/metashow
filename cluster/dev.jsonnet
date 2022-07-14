local minioSecret=std.extVar("minioSecretKey");
local bindPassword=std.extVar("bindPassword");
local grafanaUser=std.extVar("grafanaUser");
local grafanaPassword=std.extVar("grafanaPassword");
local registry="harbor.dev.21vianet.com/library/";
local grafanaHost='grafana.dev.21vianet.com';
local grafanaUrl='https://'+grafanaHost+'/';
local grafanaKey = |||
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAvp6FSB7TOWNuWMwWEMKASR+Fi4NhIgZzUoQw/LUzLSq5VIuO
        5p3g3PrfoxJXaY/wv5x2vfTmXAEckBo5rA2IzdtGxqbVxJN0jfsXP7FMJcjctGL+
        x4u05mMEFJ4N0W1Ndu1bLdTa9YKbB44iD197ILRbksGYz6QFY7VpMbqEcCcannjH
        KtDuQr+NCjFHx2oU/g5AQK8Ap1iDXgYtH5GKPq1JmwSXGT/I34ocMxdsk1Fslqpb
        jt/5v7UHnnozb8bWnFco9sSWFXv0jRxgXNbbD6PFw4C116MOYABhkSJSQCwtHAsp
        DvJ3n6W0X04bMgFp0vCFPW9Puj1mhZvkWYkiVwIDAQABAoIBABmlGAdQ5lf1MZZO
        trVAhaPQ0tWnMj0yovc6A6Er+5ubAN4H/Iy4NtVkBwxYXlw8WkZdFXiO5yL/n0kf
        zhyAoaQYWRhGv8G3mNm1KzaNctIuiMrX+rD78bWBIr5nWTKQwvg6DKdI2MBo9tR4
        YcqxrM4ElcFTvGxLA9KbSHDBSCoSTUFEMRM+/hWnLdon9kMLQsyjpeE0J4kIMHYY
        e0fpIrx1yRyTZ6qVx3SlZGMQ3tZV/vkcmVzCxVqr9T0LTfYVxd/rWPHtEk2udVg4
        ccvZ77jvRu1sS36zMw0Go+EpL8smIRL2Td5AnC4BCSBIwt7IIOrLO0sp7TtTnmwr
        7si3gTECgYEA5BEpoyWCNLq3L5GhBxGb2ZpcyCUkOwUsn0BbgRWuL+IFgexE/MSP
        GEwEYSWq2PnJ07ysnSBwLaakJk/NtcDyUaUNHqaxE3/ROdNgtnhsN2z2q01DOtIs
        pdjD5uIwNN8+w316u6leLtwtFDR/pbBSQ97cI+pFJ14lzRVeYW0iAz8CgYEA1fc3
        FweKjk8PB0kvHoHJ/1krbeuxE5YotkL6ZAVYuNLtl5coPMB7yYE8IF7jazw+4ons
        8q8Bm1Xp8nATvRVq+p++J4r8xOhHI6M8uRGhrCzpNZ4+Yg0x1dZ7MnrErTUWSYEV
        NV9aFf4sYF5RSRFKWR1zLSNHpUKanJv8RX72UukCgYEAzLoTVF6BSXAqrMrfcAcA
        jg+hJhEhOtHkQnh1K6UYnecY5o3/R5/yi+8BJ2u2t9tSr314vfu2d2RVigatNHCl
        lWDCLDeaUVS1rmDvOh1Tl1V7AD71EMJGTgINqR52A6A7KSVknTzmTM5csPyHcWac
        Ekzl9F+CAFrlN/nspSxgEeUCgYEA06Qh2OS7t8IZsnJAamOlI6/XFnZRBHe+M3KS
        7Aah2MfC/fQld9pJV2s+xyI0v2irJzeYqgBTjYvwyb70t06NL/R8ie6f0kGTxHt9
        3+3BxmXyE/g/6or0pXjvCWKIUm+1aOWGzfFQUXrF+Fiy/Jxet0E7IQXJo3z7JDfi
        0/cevakCgYAHw3luiM7f3dxZXGdfDP+m2t/EVOOa6FjOGqLwHG0abG5FyoGNztV/
        fflbwMIZ6BczrYnpDpwPmQp2CuD/0duoMTteIed7TgOdmRe7z3wjShM5rATsA1Pf
        A3fuOfG7UzNHpDoPYqXbTg3Y490WIRXsqZfy0H99FNVJrWg2NEOYCg==
        -----END RSA PRIVATE KEY-----
      |||;
local grafanaCert = |||
        -----BEGIN CERTIFICATE-----
        MIIDdTCCAl2gAwIBAgIJAIVoissb1VN8MA0GCSqGSIb3DQEBCwUAMGQxCzAJBgNV
        BAYTAkNOMQswCQYDVQQIDAJCSjELMAkGA1UEBwwCQkoxETAPBgNVBAoMCDIxdmlh
        bmV0MRcwFQYDVQQLDA5Tb2Z0d2FyZUNlbnRlcjEPMA0GA1UEAwwGcm9vdGNhMCAX
        DTIyMDUyMzA3MzI0MloYDzIxMjIwNDI5MDczMjQyWjBlMQswCQYDVQQGEwJDTjEL
        MAkGA1UECAwCQkoxCzAJBgNVBAcMAkJKMREwDwYDVQQKDAgyMXZpYW5ldDEXMBUG
        A1UECwwOU29mdHdhcmVDZW50ZXIxEDAOBgNVBAMMB2dyYWZhbmEwggEiMA0GCSqG
        SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC+noVIHtM5Y25YzBYQwoBJH4WLg2EiBnNS
        hDD8tTMtKrlUi47mneDc+t+jEldpj/C/nHa99OZcARyQGjmsDYjN20bGptXEk3SN
        +xc/sUwlyNy0Yv7Hi7TmYwQUng3RbU127Vst1Nr1gpsHjiIPX3sgtFuSwZjPpAVj
        tWkxuoRwJxqeeMcq0O5Cv40KMUfHahT+DkBArwCnWINeBi0fkYo+rUmbBJcZP8jf
        ihwzF2yTUWyWqluO3/m/tQeeejNvxtacVyj2xJYVe/SNHGBc1tsPo8XDgLXXow5g
        AGGRIlJALC0cCykO8nefpbRfThsyAWnS8IU9b0+6PWaFm+RZiSJXAgMBAAGjJzAl
        MCMGA1UdEQQcMBqCGGdyYWZhbmEuZGV2LjIxdmlhbmV0LmNvbTANBgkqhkiG9w0B
        AQsFAAOCAQEAY+7NWJd6bkoOp+Vs5LP0u1T6Z0DSXDBkKax8UwqZWSUyTHD8HlUl
        +poEFtb/jz/B9+h5gunDYvRhPi7+C2uW2yWSxH0Jd8k/hPKzaceRveGH9WAnJIUD
        DnnHcW2uGu2A3YowfC/d4Kvx4lOsDBTGdttpiT9dI8S9JaZaa4qGwJd+QhrESvnS
        Rji+ux2JG6HlflngmFBG5tCI49rA5/U4saZWrJEk1MABs50i45AU4ypQYBwHmVwb
        e1B4aOXC+UMXYlTQGCTqoJrcDX16GZexMplIaSeM3i3ysvm3iPswDHL0n4lHkJK6
        BveTQaAw92uhqwwkcYI/n74N2nw2mQkW1g==
        -----END CERTIFICATE-----
      |||;
local alertmanagerHost='alertmanager.dev.21vianet.com';
local alertmanagerUrl='https://' + alertmanagerHost;
local alertmanagerCert = |||
        -----BEGIN CERTIFICATE-----
        MIIDfzCCAmegAwIBAgIJAIVoissb1VN9MA0GCSqGSIb3DQEBCwUAMGQxCzAJBgNV
        BAYTAkNOMQswCQYDVQQIDAJCSjELMAkGA1UEBwwCQkoxETAPBgNVBAoMCDIxdmlh
        bmV0MRcwFQYDVQQLDA5Tb2Z0d2FyZUNlbnRlcjEPMA0GA1UEAwwGcm9vdGNhMCAX
        DTIyMDUyMzA3MzI1NFoYDzIxMjIwNDI5MDczMjU0WjBqMQswCQYDVQQGEwJDTjEL
        MAkGA1UECAwCQkoxCzAJBgNVBAcMAkJKMREwDwYDVQQKDAgyMXZpYW5ldDEXMBUG
        A1UECwwOU29mdHdhcmVDZW50ZXIxFTATBgNVBAMMDGFsZXJ0bWFuYWdlcjCCASIw
        DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMpq/gG6Quhcp5we4RGsN2zSK8tB
        HyYiZjkj9rYemxVcrsRBk3NzOMzurwqIXjfB/d3sgYqddN+qtraCJSrBbqorIFZG
        7tW3+rcQWbn/c7LZr2FHQdDgQgX71V30PvoYVLbto2DBDVgzLsusitQoFoBYosVs
        TAfjqYvehX8Y4xEBe5eOb1aaf7Mp+ERGnOyPNeRFz43bc/uxXLDf5DEnBFNVnF/A
        79mZ6BfR00NFW1bxWVEg3xoJ9NYajHNYgXHUrL4lfGU2DNNZluskEy2QIpLcl+gq
        Ehp+R9HVV/IkRN71FMGSOYEXI+VyGtvnS4hH/AMZ/nqz1m0TaK+yNzF7jvMCAwEA
        AaMsMCowKAYDVR0RBCEwH4IdYWxlcnRtYW5hZ2VyLmRldi4yMXZpYW5ldC5jb20w
        DQYJKoZIhvcNAQELBQADggEBALq6wIGl6oLC017kmGD1+yeJ4xNxUvO1gJF9/FNr
        vTUfMQsOlYuGUxF14ntwA6B9ldiA4FcvJilY9XfSysNumBFI2/Drgy62XJ9EMZxw
        Zr+wOnGFv41YzS86YoAzdbORg9wpSHQMp5yIDQVHo5EjI0u53tScIulL9Fb7Xmve
        msNK3aQgbQFWcFQem76EresiwbjGVelHunEGF8ijlFJY6qXnx6x6AHDjci/78MNm
        w7hYtNibgMMqHPVvObkkC4s57l+e4dBrDso4ypZToJyEMo1fIB2kM1ydtMEIaw27
        cppI91hfpC/6NsaGwLZH3vhyYBkDqjsiizfPab0eWWYNA+Q=
        -----END CERTIFICATE-----
      |||;
local alertmanagerKey = |||
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAymr+AbpC6FynnB7hEaw3bNIry0EfJiJmOSP2th6bFVyuxEGT
        c3M4zO6vCoheN8H93eyBip1036q2toIlKsFuqisgVkbu1bf6txBZuf9zstmvYUdB
        0OBCBfvVXfQ++hhUtu2jYMENWDMuy6yK1CgWgFiixWxMB+Opi96FfxjjEQF7l45v
        Vpp/syn4REac7I815EXPjdtz+7FcsN/kMScEU1WcX8Dv2ZnoF9HTQ0VbVvFZUSDf
        Ggn01hqMc1iBcdSsviV8ZTYM01mW6yQTLZAiktyX6CoSGn5H0dVX8iRE3vUUwZI5
        gRcj5XIa2+dLiEf8Axn+erPWbRNor7I3MXuO8wIDAQABAoIBAQCIrhhYWEpnlnED
        JYK6qTw/uecidxWubVnzSYqEzUPQ9+V21gTX1zzKfH0rsotUQSTIHrQWQl4xzZdU
        w6qPJVAxja9nMryBCZs808iSpKCeawlWuYQCo/tRCQy5RXzk6VsCrpI8ef8lyGHX
        2+leerc+8RrwDkGErkDFFnu0J7zjtJYZRg2irI2W66ktBF3VFXeTzI25+UlMeGFF
        s8emcfu3+1A+2CLVWcqD19ftzpnLe641lFXsOjhtQD37Edv2Zbzjsxjr9NzBV11y
        5PbytqyuCZoj07pxWNyS2+o9FAVqJrJMjkILO+A6mYVyeNOVVgzqmBqpFkOKSZxg
        FsfOXEhJAoGBAOk72sgoDsLpiNkvkHT/AXLLDP4aqMj7ae1IF/1g0DlriP/zuQ02
        vjNN3fk6pTShE5IHjyek3Q2hSWlwdeTOgIeVBgG0k3QT7ox8RyFLxjYGBaXBGt1v
        eLB+s7qCUU+4kgzAbQnaQSUeDAWRxmQsedh0i8EyYBnXtLu9S51Fjs1/AoGBAN4t
        GPtyTy3tIsFNrx9UNhCQFXsYcDHdxhvqQ69tfoc70zRbLtNQnEUCTqFEr/U5yeRG
        K5ktGya3WYm7dbF3z3vW3gZso/UyAU4jZAAe20bI9HKt7gQe3m176YMk9zhtdDQ+
        /pADl34G6a8a1FcMDnRDqfiHFROaUiLFIgWLG6CNAoGAFeIUy/TeNbF9sosA7clD
        VIbyqCDON1VHggjin1ZnEwwg5YrzkObS/7NNoWW8PGzkji4BY4HXb8DzR15S4W3y
        p0X3M0/DCgAYwLukXN5kMYttGjk9EQu1cjHhIR27DVTO9z1Svbrpo9bm39rml12I
        7SM6PZ1BYQtZHMhNAOuW03cCgYA7/bFhM9xtajqYN4Gx0+tFTaJ/OnoQ/PEhWIAu
        PkKMAXtmB7j9Ficb+yOAKCva61+4Y7oiAivyqE9lAVkmMlOz/LC2y176NiZkEupN
        ngdXdauLy6sZMbydk3faEYEvm15lPR0/hbjCLtuqjHQJjRfaDOs4UEFAqcrD2Lb3
        CDjNgQKBgQCYYSzzyIN1A8lEHBQuGTBEv9ubaLG24iFQWP+qIzo4TY/EByASCDty
        3l71EqOQ6IsJ81jJ9iiy77NntgFIhzrRavsC4ZelZ4IQCc9luTAB3FOxAl9UEMLV
        1lYqJ++dMXACGy4C6i3odn8GocMh8l8NAa5McignOT2Kp7pcrJr2iA==
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
          cluster: 'dev',
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
        extralAlertmanagers: [{namespace: 'kube-admin', name: 'monitor-kube-prometheus-st-alertmanager' , port: 'http-web', apiVersion: 'v2',}],
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
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule' && !std.startsWith(name, '0') ), std.objectFields(kp.prometheusOperator))
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


