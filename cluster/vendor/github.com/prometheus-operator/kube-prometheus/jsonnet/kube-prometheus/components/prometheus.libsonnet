local defaults = {
  local defaults = self,
  namespace: error 'must provide namespace',
  version: error 'must provide version',
  image: error 'must provide image',
  resources: {
    requests: { memory: '400Mi' },
  },

  name: error 'must provide name',
  alertmanagerName: error 'must provide alertmanagerName',
  namespaces: ['default', 'kube-system', defaults.namespace],
  replicas: 2,
  externalLabels: {},
  commonLabels:: {
    'app.kubernetes.io/name': 'prometheus',
    'app.kubernetes.io/version': defaults.version,
    'app.kubernetes.io/component': 'prometheus',
    'app.kubernetes.io/part-of': 'kube-prometheus',
  },
  selectorLabels:: {
    [labelName]: defaults.commonLabels[labelName]
    for labelName in std.objectFields(defaults.commonLabels)
    if !std.setMember(labelName, ['app.kubernetes.io/version'])
  } + { prometheus: defaults.name },
  ruleSelector: {
    matchLabels: defaults.mixin.ruleLabels,
  },
  mixin: {
    ruleLabels: {
      role: 'alert-rules',
      prometheus: defaults.name,
    },
    _config: {
      prometheusSelector: 'job="prometheus-' + defaults.name + '",namespace="' + defaults.namespace + '"',
      prometheusName: '{{$labels.namespace}}/{{$labels.pod}}',
      thanosSelector: 'job="thanos-sidecar"',
      runbookURLPattern: 'https://github.com/prometheus-operator/kube-prometheus/wiki/%s',
    },
  },
  thanos: {},
  minio: "",
  extralAlertmanagers: [],
  additionalAlertManagerConfigs: "",
};


function(params) {
  local p = self,
  _config:: defaults + params,
  // Safety check
  assert std.isObject(p._config.resources),
  assert std.isObject(p._config.mixin._config),

  mixin:: (import 'github.com/prometheus/prometheus/documentation/prometheus-mixin/mixin.libsonnet') +
          (import 'github.com/kubernetes-monitoring/kubernetes-mixin/alerts/add-runbook-links.libsonnet') + (
    if p._config.thanos != {} then
      (import 'github.com/thanos-io/thanos/mixin/alerts/sidecar.libsonnet') + {
        sidecar: {
          selector: p._config.mixin._config.thanosSelector,
        },
      }
    else {}
  ) {
    _config+:: p._config.mixin._config,
  },


  local hasSideCar = std.objectHas(params, 'thanos') && std.length(params.thanos) > 0,
  local replicas = if hasSideCar then std.range(0, p._config.replicas-1) else [],
  local sideSvcs = [
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata+: {
        name: 'prometheus-' + p._config.name + '-sidecar-' + ind,
        namespace: p._config.namespace,
        labels+: p._config.commonLabels {
          prometheus: p._config.name,
          'app.kubernetes.io/component': 'thanos-sidecar-' + ind,
        },
      },
      spec+: {
        ports: [
          { name: 'grpc', port: 10901, targetPort: 10901 },
          { name: 'http', port: 10902, targetPort: 10902 },
        ],
        selector: p._config.selectorLabels {
          prometheus: p._config.name,
          'app.kubernetes.io/component': 'prometheus',
          'statefulset.kubernetes.io/pod-name': 'prometheus-k8s-' + ind,
        },
        sessionAffinity: 'ClientIP',
        type: 'NodePort',
      },
    }
    for ind in replicas
  ],

  thanosSideCarEachService: {
    [side.metadata.name]: side for side in sideSvcs
  },

  prometheusRule: {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PrometheusRule',
    metadata: {
      labels: p._config.commonLabels + p._config.mixin.ruleLabels,
      name: 'prometheus-' + p._config.name + '-prometheus-rules',
      namespace: p._config.namespace,
    },
    spec: {
      local r = if std.objectHasAll(p.mixin, 'prometheusRules') then p.mixin.prometheusRules.groups else [],
      local a = if std.objectHasAll(p.mixin, 'prometheusAlerts') then p.mixin.prometheusAlerts.groups else [],
      groups: a + r,
    },
  },

  serviceAccount: {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: 'prometheus-' + p._config.name,
      namespace: p._config.namespace,
      labels: p._config.commonLabels,
    },
  },

  service: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'prometheus-' + p._config.name,
      namespace: p._config.namespace,
      labels: { prometheus: p._config.name } + p._config.commonLabels,
    },
    spec: {
      ports: [
               { name: 'web', targetPort: 'web', port: 9090 },
             ] +
             (
               if p._config.thanos != {} then
                 [{ name: 'grpc', port: 10901, targetPort: 10901 }]
               else []
             ),
      selector: { app: 'prometheus' } + p._config.selectorLabels,
      sessionAffinity: 'ClientIP',
    },
  },

  roleBindingSpecificNamespaces:
    local newSpecificRoleBinding(namespace) = {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'RoleBinding',
      metadata: {
        name: 'prometheus-' + p._config.name,
        namespace: namespace,
        labels: p._config.commonLabels,
      },
      roleRef: {
        apiGroup: 'rbac.authorization.k8s.io',
        kind: 'Role',
        name: 'prometheus-' + p._config.name,
      },
      subjects: [{
        kind: 'ServiceAccount',
        name: 'prometheus-' + p._config.name,
        namespace: p._config.namespace,
      }],
    };
    {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'RoleBindingList',
      items: [newSpecificRoleBinding(x) for x in p._config.namespaces],
    },

  clusterRole: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'ClusterRole',
    metadata: {
      name: 'prometheus-' + p._config.name,
      labels: p._config.commonLabels,
    },
    rules: [
      {
        apiGroups: [''],
        resources: ['nodes/metrics'],
        verbs: ['get'],
      },
      {
        nonResourceURLs: ['/metrics'],
        verbs: ['get'],
      },
    ],
  },

  roleConfig: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'Role',
    metadata: {
      name: 'prometheus-' + p._config.name + '-config',
      namespace: p._config.namespace,
      labels: p._config.commonLabels,
    },
    rules: [{
      apiGroups: [''],
      resources: ['configmaps'],
      verbs: ['get'],
    }],
  },

  roleBindingConfig: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'RoleBinding',
    metadata: {
      name: 'prometheus-' + p._config.name + '-config',
      namespace: p._config.namespace,
      labels: p._config.commonLabels,
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'Role',
      name: 'prometheus-' + p._config.name + '-config',
    },
    subjects: [{
      kind: 'ServiceAccount',
      name: 'prometheus-' + p._config.name,
      namespace: p._config.namespace,
    }],
  },

  clusterRoleBinding: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'ClusterRoleBinding',
    metadata: {
      name: 'prometheus-' + p._config.name,
      labels: p._config.commonLabels,
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'ClusterRole',
      name: 'prometheus-' + p._config.name,
    },
    subjects: [{
      kind: 'ServiceAccount',
      name: 'prometheus-' + p._config.name,
      namespace: p._config.namespace,
    }],
  },

  roleSpecificNamespaces:
    local newSpecificRole(namespace) = {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'Role',
      metadata: {
        name: 'prometheus-' + p._config.name,
        namespace: namespace,
        labels: p._config.commonLabels,
      },
      rules: [
        {
          apiGroups: [''],
          resources: ['services', 'endpoints', 'pods'],
          verbs: ['get', 'list', 'watch'],
        },
        {
          apiGroups: ['extensions'],
          resources: ['ingresses'],
          verbs: ['get', 'list', 'watch'],
        },
        {
          apiGroups: ['networking.k8s.io'],
          resources: ['ingresses'],
          verbs: ['get', 'list', 'watch'],
        },
      ],
    };
    {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'RoleList',
      items: [newSpecificRole(x) for x in p._config.namespaces],
    },

  [if (defaults + params).replicas > 1 then 'podDisruptionBudget']: {
    apiVersion: 'policy/v1beta1',
    kind: 'PodDisruptionBudget',
    metadata: {
      name: 'prometheus-' + p._config.name,
      namespace: p._config.namespace,
      labels: p._config.commonLabels,
    },
    spec: {
      minAvailable: 1,
      selector: {
        matchLabels: {
          prometheus: p._config.name,
        } + p._config.selectorLabels,
      },
    },
  },

  [ if (defaults + params).additionalAlertManagerConfigs != "" then 'additionalAlertmanagersSecret' ]: {
    apiVersion: 'v1',
    kind: 'Secret',
    type: 'Opaque',
    metadata: {
      name: 'prometheus-additionall-alertmanager',
      namespace: p._config.namespace,
    },
    data: {
      'additional-alertmanager-configs.yaml' : std.base64(p._config.additionalAlertManagerConfigs),
    },    
  },

  prometheus: {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'Prometheus',
    metadata: {
      name: p._config.name,
      namespace: p._config.namespace,
      labels: { prometheus: p._config.name } + p._config.commonLabels,
    },
    spec: {
      [ if (defaults + params).additionalAlertManagerConfigs != "" then 'additionalAlertManagerConfigs'] : {
        name: 'prometheus-additionall-alertmanager',
        key: 'additional-alertmanager-configs.yaml',
      },
      replicas: p._config.replicas,
      version: p._config.version,
      image: p._config.image,
      podMetadata: {
        labels: p._config.commonLabels,
      },
      externalLabels: p._config.externalLabels,
      serviceAccountName: 'prometheus-' + p._config.name,
      serviceMonitorSelector: {},
      podMonitorSelector: {},
      probeSelector: {},
      serviceMonitorNamespaceSelector: {},
      podMonitorNamespaceSelector: {},
      probeNamespaceSelector: {},
      nodeSelector: { 'kubernetes.io/os': 'linux' },
      ruleSelector: p._config.ruleSelector,
      resources: p._config.resources,
      alerting: {
        alertmanagers: [{
          namespace: p._config.namespace,
          name: 'alertmanager-' + p._config.alertmanagerName,
          port: 'web',
          apiVersion: 'v2',
        }] + p._config.extralAlertmanagers,
      },
      securityContext: {
        runAsUser: 1000,
        runAsNonRoot: true,
        fsGroup: 2000,
      },
      storage: {
        volumeClaimTemplate: {
          spec: {
            storageClassName: 'csi-rbd-sc',
            resources: {
              requests: {
                storage: '40Gi',
              },
            },
          },
        },
      },
      [if std.objectHas(params, 'thanos') then 'thanos']: p._config.thanos,
    },
  },

  [if std.objectHas(params, 'thanos') then 'secretSideCar']: {
    apiVersion: 'v1',
    kind: 'Secret',
    type: 'Opaque',
    metadata: {
      name: 'minio',
      namespace: p._config.namespace,
    },
    data: {
      'object-store.yaml': std.base64(p._config.minio),
    },
  },

  serviceMonitor: {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'ServiceMonitor',
    metadata: {
      name: 'prometheus-' + p._config.name,
      namespace: p._config.namespace,
      labels: p._config.commonLabels,
    },
    spec: {
      selector: {
        matchLabels: p._config.selectorLabels,
      },
      endpoints: [{
        port: 'web',
        interval: '30s',
      }],
    },
  },

  // Include thanos sidecar Service only if thanos config was passed by user
  [if std.objectHas(params, 'thanos') && std.length(params.thanos) > 0 then 'serviceThanosSidecar']: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata+: {
      name: 'prometheus-' + p._config.name + '-thanos-sidecar',
      namespace: p._config.namespace,
      labels+: p._config.commonLabels {
        prometheus: p._config.name,
        'app.kubernetes.io/component': 'thanos-sidecar',
      },
    },
    spec+: {
      ports: [
        { name: 'grpc', port: 10901, targetPort: 10901 },
        { name: 'http', port: 10902, targetPort: 10902 },
      ],
      selector: p._config.selectorLabels {
        prometheus: p._config.name,
        'app.kubernetes.io/component': 'prometheus',
      },
      clusterIP: 'None',
    },
  },
  
  // Include thanos sidecar ServiceMonitor only if thanos config was passed by user
  [if std.objectHas(params, 'thanos') && std.length(params.thanos) > 0 then 'serviceMonitorThanosSidecar']: {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'ServiceMonitor',
    metadata+: {
      name: 'thanos-sidecar',
      namespace: p._config.namespace,
      labels: p._config.commonLabels {
        prometheus: p._config.name,
        'app.kubernetes.io/component': 'thanos-sidecar',
      },
    },
    spec+: {
      jobLabel: 'app.kubernetes.io/component',
      selector: {
        matchLabels: {
          prometheus: p._config.name,
          'app.kubernetes.io/component': 'thanos-sidecar',
        },
      },
      endpoints: [{
        port: 'http',
        interval: '30s',
      }],
    },
  },
}
