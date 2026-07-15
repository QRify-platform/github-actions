# terraform-setup

Prepares a job to run Terraform against the QRify managed stack.

```yaml
- uses: QRify-platform/github-actions/terraform-setup@main
  with:
    aws-role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
    aws-region: us-east-2

- run: terraform plan
```

After this action, AWS credentials are available for later steps in the same job (e.g. kubectl against EKS).
