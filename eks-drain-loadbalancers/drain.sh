#!/usr/bin/env bash
# Scale down Argo controllers, delete LoadBalancer Services, wait for ELB ENIs.
# Expects kubeconfig already pointed at the target cluster.
set -u

CLUSTER_NAME="${CLUSTER_NAME:-qrify-eks}"
AWS_REGION="${AWS_REGION:-us-east-2}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-24}"
SLEEP_SECONDS="${SLEEP_SECONDS:-15}"

set +e
if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "Cluster not reachable; skipping LoadBalancer drain"
  exit 0
fi
set -e

# Newer Argo charts use a StatefulSet; older use a Deployment.
kubectl -n argocd scale statefulset/argocd-application-controller --replicas=0 --timeout=60s || true
kubectl -n argocd scale deployment/argocd-application-controller --replicas=0 --timeout=60s || true
kubectl -n argocd delete applications.argoproj.io --all --wait=false || true

kubectl get svc -A -o json \
  | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "\(.metadata.namespace)\t\(.metadata.name)"' \
  | while IFS=$'\t' read -r ns name; do
      echo "Deleting LoadBalancer service ${ns}/${name}"
      kubectl delete svc -n "$ns" "$name" --wait=true --timeout=5m || true
    done

VPC_ID=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" \
  --query 'cluster.resourcesVpcConfig.vpcId' --output text 2>/dev/null || true)
if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
  echo "Could not resolve VPC id; continuing"
  exit 0
fi

echo "Waiting for ELB ENIs in ${VPC_ID} to clear (ignoring NAT/node public IPs)..."
for i in $(seq 1 "$MAX_ATTEMPTS"); do
  COUNT=$(aws ec2 describe-network-interfaces \
    --filters "Name=vpc-id,Values=${VPC_ID}" \
    --query 'length(NetworkInterfaces[?starts_with(Description, `ELB`)])' \
    --output text)
  echo "Attempt ${i}: ${COUNT} ELB ENI(s)"
  if [ "$COUNT" = "0" ]; then
    exit 0
  fi
  sleep "$SLEEP_SECONDS"
done

echo "Timed out waiting for ELB ENIs; continuing"
exit 0
