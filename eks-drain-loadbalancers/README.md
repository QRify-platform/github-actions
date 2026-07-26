# eks-drain-loadbalancers

Removes Kubernetes LoadBalancer Services and waits for ELB ENIs before `terraform destroy`.

```yaml
- uses: QRify-platform/github-actions/terraform-setup@v1.0.0
  with:
    aws-role-to-assume: ${{ vars.AWS_TF_ROLE_TO_ASSUME }}

# AWS creds already in the job — omit aws-role-to-assume
- uses: QRify-platform/github-actions/eks-drain-loadbalancers@v1.0.0
  with:
    cluster-name: qrify-eks
    aws-region: us-east-2

- run: terraform destroy -auto-approve
```
