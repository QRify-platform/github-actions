# terraform-setup

Prepares a job to run Terraform against the QRify managed stack.

```yaml
- uses: QRify-platform/github-actions/terraform-setup@main
  with:
    aws-role-to-assume: ${{ vars.AWS_TF_ROLE_TO_ASSUME }}
    aws-region: us-east-2

- run: terraform plan
```

After this action, AWS credentials are available for later steps in the same job (e.g. kubectl against EKS).
