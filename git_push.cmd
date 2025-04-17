cd /d %~dp0
git add charts/helm-gogs/values.generated.yaml
git commit -m "update dynamic values"
git push