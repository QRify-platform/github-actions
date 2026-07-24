# QRify GitHub Actions

Reusable **composite actions** for the QRify platform. App repos and infra workflows call these so OIDC, Terraform, ECR, and EKS setup stay consistent.

## Actions

| Action | Purpose |
|---|---|
| [`terraform-setup`](./terraform-setup) | Checkout + AWS OIDC + Terraform install + `init` |
| [`eks-kubeconfig`](./eks-kubeconfig) | Install kubectl and point at EKS |
| [`eks-drain-loadbalancers`](./eks-drain-loadbalancers) | Delete LB Services / wait for ELB ENIs before destroy |
| [`docker-build-push`](./docker-build-push) | Build image and push to ECR (tag = short SHA) |
| [`ecr-retag`](./ecr-retag) | Copy an existing ECR tag from one repo to another (promote) |
| [`update-app-tag`](./update-app-tag) | Bump `imageTag` in `cluster-state` and push |
| [`dispatch-and-wait`](./dispatch-and-wait) | `workflow_dispatch` another repo and wait for the run |

## Example (app release — build once, promote to prod)

App repos use a single `release.yaml`: push to `main` builds → `*-dev` ECR + `values.dev.yaml`. Prod promote is manual only (`workflow_dispatch`): same SHA retagged into `*-prod` and `values.prod.yaml`.

```yaml
jobs:
  deploy-dev:
    runs-on: ubuntu-latest
    outputs:
      tag: ${{ steps.build.outputs.tag }}
    steps:
      - uses: actions/checkout@v4
      - id: build
        uses: QRify-platform/github-actions/docker-build-push@main
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

  promote-prod:
    needs: deploy-dev
    if: github.event_name == 'workflow_dispatch'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: QRify-platform/github-actions/ecr-retag@main
        with:
          source-image-name: qrify-web-dev
          target-image-name: qrify-web-prod
          image-tag: ${{ needs.deploy-dev.outputs.tag }}
          aws-role-to-assume: ${{ vars.AWS_ECR_ROLE_TO_ASSUME }}
          aws-region: us-east-2
          ecr-registry: ${{ vars.AWS_ECR_REGISTRY }}
      - uses: QRify-platform/github-actions/update-app-tag@main
        with:
          image-tag: ${{ needs.deploy-dev.outputs.tag }}
          github-token: ${{ secrets.CLUSTER_STATE_PAT }}
          cluster-repo: QRify-platform/cluster-state
          values-file-path: apps/qrify-web/values.prod.yaml
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

## Organization variables (OIDC roles)

Set these once from bootstrap outputs (`cd infra/bootstrap && terraform output`):

| Variable | Bootstrap output | Used by |
|---|---|---|
| `AWS_TF_ROLE_TO_ASSUME` | `terraform_role_arn` | `infra` |
| `AWS_ECR_ROLE_TO_ASSUME` | `ecr_push_role_arn` | app release workflows |
| `AWS_EKS_ROLE_TO_ASSUME` | `eks_access_role_arn` | `cluster-state` Argo sync |
| `AWS_SECRETS_ROLE_TO_ASSUME` | `secrets_role_arn` | `secrets-manager` |
| `AWS_ECR_REGISTRY` | *(account).dkr.ecr.us-east-2.amazonaws.com* | app release workflows |

## Layout

```text
<action-name>/
├── action.yaml
├── README.md
└── *.sh          # optional
```
