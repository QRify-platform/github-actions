# QRify GitHub Actions

This repository contains reusable **composite GitHub Actions** designed for the QRify Platform to support CI/CD workflows, cloud automation, and DevOps best practices.

> These actions are meant to be consumed across the QRify platform's microservices and infrastructure repositories.



## 🧱 Structure

Each action is stored in its own folder with the following layout:

```
<action-name>/
├── action.yml         # Composite action definition
├── README.md          # Usage documentation
└── other files        # (optional) scripts, templates, etc.
```

---

## 🧪 Example Usage

In any QRify repo:

```yaml
- uses: QRify-platform/github-actions/docker-build-push-ecr@main
  with:
    image-name: qrify-web-dev
```

> See the specific action folder for more usage examples and required environment variables.

---

## ✅ Best Practices

- Keep actions modular and language-agnostic
- Use [OpenID Connect](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect) for AWS authentication
- Store secrets in GitHub org/repo settings and reference via `${{ secrets.NAME }}`


