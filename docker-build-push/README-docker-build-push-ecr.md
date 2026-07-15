# Docker Build & Push to ECR (Composite GitHub Action)

This composite GitHub Action builds a Docker image from the current repository and pushes it to Amazon Elastic Container Registry (ECR) using the Git commit SHA as the image tag.

> ✅ Designed for GitOps workflows with ArgoCD + Kubernetes

---

## 🚀 Usage

In your workflow:

```yaml
- uses: QRify-platform/github-actions/docker-build-push@mv1
  with:
    image-name: qrify-web-dev
```

---

## 📥 Inputs

| Name        | Required | Description                                               |
|-------------|----------|-----------------------------------------------------------|
| `image-name` | ✅        | Name of the ECR repository (e.g. `qrify-web-dev`)         |

---

## 🌍 Required Environment Variables

These **must be defined in the calling workflow** at the job or step level:

| Env Variable         | Required | Example                                               | Description                                             |
|----------------------|----------|-------------------------------------------------------|---------------------------------------------------------|
| `AWS_ECR_ROLE_TO_ASSUME` | ✅        | `arn:aws:iam::123456789012:role/QRifyECRPushRole` | The IAM role this workflow assumes using OIDC          |
| `AWS_REGION`         | ✅        | `us-east-1`                                           | AWS region where your ECR registry is hosted           |
| `ECR_REGISTRY`       | ✅        | `123456789012.dkr.ecr.us-east-1.amazonaws.com`        | Full domain of your ECR registry                       |

---

## Required GitHub Variables

Role ARNs and registry hostnames are not credentials — use **organization variables**:

- `AWS_ECR_ROLE_TO_ASSUME`
- `AWS_ECR_REGISTRY`

---

## Example Workflow

```yaml
name: Release to Dev

on:
  push:
    branches: [main]

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Build and push to ECR
        uses: QRify-platform/github-actions/docker-build-push@main
        with:
          image-name: qrify-web-dev
          aws-role-to-assume: ${{ vars.AWS_ECR_ROLE_TO_ASSUME }}
          aws-region: us-east-2
          ecr-registry: ${{ vars.AWS_ECR_REGISTRY }}
```

---

## 🏷 Image Tag Format

This action automatically tags images using the **first 8 characters** of the commit SHA:
---

## 🧱 Project Structure

This action is meant to live at the root of its folder for simple usage. Avoid placing it under `.github/actions/` unless it's local-only.

---

## 🙋 Support

Need help or want to extend this action? Open a PR or reach out in the platform channel.
