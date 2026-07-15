# dispatch-and-wait

Triggers a workflow on another repository and blocks until it completes.

```yaml
- uses: QRify-platform/github-actions/dispatch-and-wait@main
  with:
    repository: QRify-platform/cluster-state
    workflow: argo-sync.yaml
    github-token: ${{ secrets.GH_DISPATCH_TOKEN }}
```
