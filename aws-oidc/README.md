# aws-oidc

Configures AWS credentials in the job using GitHub OIDC.

```yaml
- uses: QRify-platform/github-actions/aws-oidc@main
  with:
    aws-role-to-assume: ${{ vars.AWS_ECR_ROLE_TO_ASSUME }}
    aws-region: us-east-2
```

Requires `permissions: id-token: write`.
