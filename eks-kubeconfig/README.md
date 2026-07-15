# eks-kubeconfig

Installs kubectl and writes kubeconfig for an EKS cluster.

```yaml
# When the job already has AWS credentials (e.g. after terraform-setup):
- uses: QRify-platform/github-actions/eks-kubeconfig@main
  with:
    aws-region: us-east-2
    cluster-name: qrify-eks

# Or assume a role first:
- uses: QRify-platform/github-actions/eks-kubeconfig@main
  with:
    aws-role-to-assume: ${{ secrets.AWS_EKS_ROLE_TO_ASSUME }}
    aws-region: us-east-2
    cluster-name: qrify-eks
```
