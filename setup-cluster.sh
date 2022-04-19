#!/bin/bash
set -eu

CLUSTER_NAME=${CLUSTER_NAME:-kind}

if [[ "${INSTALL_KIND:-no}" == "yes" ]]; then
    rm -f ./kind
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
    chmod a+x ./kind
    sudo mv ./kind /usr/local/bin/kind
fi

kind create cluster --name="${CLUSTER_NAME}" --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
featureGates:
 EphemeralContainers: true
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 32100
    hostPort: 32100
    protocol: TCP
  extraMounts:
  - hostPath: /tmp/pods
    containerPath: /var/log/pods
    # optional: if set, the mount is read-only.
    # default false
    readOnly: false
    # optional: if set, the mount needs SELinux relabeling.
    # default false
    selinuxRelabel: false
    # optional: set propagation mode (None, HostToContainer or Bidirectional)
    # see https://kubernetes.io/docs/concepts/storage/volumes/#mount-propagation
    # default None
    propagation: Bidirectional
EOF

echo -e '\nKind cluster started!\n'

kubectl get nodes -owide