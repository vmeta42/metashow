{
  values+:: {
    nodeExporter+: {
      resources: {
        requests: { cpu: '600m', memory: '180Mi' },
        limits: { cpu: '600m', memory: '180Mi' },
      },
    },
    blackboxExporter+: {
      resources: {
        requests: { cpu: '100m', memory: '20Mi' },
        limits: { cpu: '100m', memory: '40Mi' },
      },
    },
    kubeStateMetrics+: {
      resources: {
        requests: { cpu: '500m', memory: '250Mi' },
        limits: { cpu: '500m', memory: '250Mi' },
      },
    },
  },
}