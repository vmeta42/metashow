local ingress(name, namespace, rules, tls=[]) = {
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: name,
    namespace: namespace,
    annotations: {
      'kubernetes.io/ingress.class': 'traefik',
      'traefik.ingress.kubernetes.io/router.entrypoints': "websecure,web",
      'traefik.ingress.kubernetes.io/router.tls': "true",
    },
  },
  spec: { 
    rules: rules,
    [if std.length(tls) > 0 then 'tls']: tls,
  },
};

local secret(name, namespace, cert, key) = {
  apiVersion: 'v1',
  kind: 'Secret',
  type: 'kubernetes.io/tls',
  metadata: {
    name: name,
    namespace: namespace,
  },
  data: {
    'tls.crt': std.base64(cert),
    'tls.key': std.base64(key),
  },
};

local defaults = {
  namespace: error 'must provide namespace',
  alertmanager:: {
    Name: 'alertmanager-main',
    Host: 'alertmanager.example.com',
    Cert: '',
    Key: '',
  },
  grafana:: {
    Name: 'grafana',
    Host: 'grafana-m6.chanty.21vianet.com',
    Cert: '',
    Key: '',
  },
};

function(params) {
  local ing = self,
  _config:: defaults + params,
  // Create ingress objects per application
  [if std.length((defaults + params).alertmanager.Cert) > 0 && std.length((defaults + params).alertmanager.Key) > 0 then (defaults + params).alertmanager.Name + '-secret']: secret(
    ing._config.alertmanager.Name + '-tls',
    ing._config.namespace,
    ing._config.alertmanager.Cert,
    ing._config.alertmanager.Key,
  ),

  [(defaults + params).alertmanager.Name+"-ingress"]: ingress(
    ing._config.alertmanager.Name,
    ing._config.namespace,
    [{
      host: ing._config.alertmanager.Host,
      http: {
        paths: [{
          path: '/',
          pathType: 'Prefix',
          backend: {
            service: {
              name: 'alertmanager-main',
              port: {
                name: 'web',
              },
            },
          },
        }],
      },
    }],
    [{
      hosts: [ing._config.alertmanager.Host],
      secretName: ing._config.alertmanager.Name + '-tls',
    }],
  ),

  [if std.length((defaults + params).grafana.Cert) > 0 && std.length((defaults + params).grafana.Key) > 0 then (defaults + params).grafana.Name+'-secret']: secret(
    ing._config.grafana.Name + '-tls',
    ing._config.namespace,
    ing._config.grafana.Cert,
    ing._config.grafana.Key,
  ),

  [(defaults + params).grafana.Name+'-ingress']: ingress(
    ing._config.grafana.Name,
    ing._config.namespace,
    [{
      host: ing._config.grafana.Host,
      http: {
        paths: [{
          path: '/',
          pathType: 'Prefix',
          backend: {
            service: {
              name: 'grafana',
              port: {
                name: 'http',
              },
            },
          },
        }],
      },
    }],
    [{
      hosts: [ing._config.grafana.Host],
      secretName: ing._config.grafana.Name + '-tls',
    }],
  ),
}
