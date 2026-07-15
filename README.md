# QRify GitHub Actions

Reusable **composite actions** for the QRify platform. App repos and infra workflows call these so OIDC, Terraform, ECR, and EKS setup stay consistent.

## Actions

| Action | Purpose |
|---|---|
| [`aws-oidc`](./aws-oidc) | Assume an IAM role via GitHub OIDC |
| [`terraform-setup`](./terraform-setup) | Checkout + AWS OIDC + Terraform install + `init` |
| [`eks-kubeconfig`](./eks-kubeconfig) | Install kubectl and point at EKS |
| [`eks-drain-loadbalancers`](./eks-drain-loadbalancers) | Delete LB Services / wait for ELB ENIs before destroy |
| [`docker-build-push`](./docker-build-push) | Build image and push to ECR (tag = short SHA) |
| [`update-app-tag`](./update-app-tag) | Bump `imageTag` in `cluster-state` and push |
| [`dispatch-and-wait`](./dispatch-and-wait) | `workflow_dispatch` another repo and wait for the run |

## Example (app release)

```yaml
- uses: actions/checkout@v4

- uses: QRify-platform/github-actions/docker-build-push@main
  id: build
  with:
    image-name: qrify-web-dev
    aws-role-to-assume: ${{ vars.AWS_ECR_ROLE_TO_ASSUME }}
    aws-region: us-east-2
    ecr-registry: ${{ vars.AWS_ECR_REGISTRY }}

- uses: QRify-platform/github-actions/update-app-tag@main
  with:
    image-tag: ${{ steps.build.outputs.tag }}
    github-token: ${{ secrets.CLUSTER_STATE_PAT }}
    cluster-repo: QRify-platform/cluster-state
    values-file-path: apps/qrify-web/values.dev.yaml
```

## Example (infra)

```yaml
- uses: QRify-platform/github-actions/terraform-setup@main
  with:
    aws-role-to-assume: ${{ vars.AWS_TF_ROLE_TO_ASSUME }}
    aws-region: us-east-2

- run: terraform apply -auto-approve
```

## Conventions

- Prefer **OIDC** over long-lived AWS keys (`permissions: id-token: write`)
- Keep bash in action scripts (`*.sh`) and invoke via `${{ github.action_path }}`
- Pin consumer workflows to `@main` (or a tag) for the org; bump deliberately when changing contracts
- One folder per action: `action.yaml` + README (+ optional scripts)

## Layout

```text
<action-name>/
├── action.yaml
├── README.md
└── *.sh          # optional
```
