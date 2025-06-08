# 🛠 Update Cluster-State Image Tag

This GitHub **composite action** updates the `imageTag` field in a `values.yaml` file within the [`cluster-state`](https://github.com/QRify-platform/cluster-state) repository. It is used to automatically propagate new Docker image tags to the appropriate environment configuration.

## 📋 What It Does

- Checks out the `cluster-state` repo
- Downloads and executes a script to update the specified `values.yaml` file
- Commits and pushes the change with a message indicating the updated image tag

## 📦 Usage

```yaml
- name: Update image tag in cluster-state
  uses: QRify-platform/github-actions/update-app-tag@main
  with:
    image-tag: ${{ steps.build.outputs.tag }}         # e.g. commit SHA or semver
    github-token: ${{ secrets.CLUSTER_STATE_PAT }}    # Personal Access Token with write access
    cluster-repo: QRify-platform/cluster-state         # Repo to update
    values-file-path: apps/qrify-web-api/values.dev.yaml
