# Helm Charts

[Repository cloned from Renovate Helm Charts](https://github.com/renovatebot/helm-charts)

## Kubernetes version support

- [Amazon Elastic Kubernetes Service (Amazon EKS)](https://endoflife.date/amazon-eks)

## Add Helm repository

```bash
helm repo add dnd-it https://dnd-it.github.io/helm-charts
helm repo update
```

## Install chart

Using config from a file:

```bash
helm install --generate-name --set-file renovate.config=config.json renovate/renovate
```

Using config from a string:

```bash
helm install --generate-name --set renovate.config='\{\"token\":\"...\"\}' renovate/renovate
```

**Note**: `renovate.config` must be a valid Renovate [self-hosted configuration](https://docs.renovatebot.com/self-hosted-configuration/).

## Contributing

When using this repo locally or contributing to this repo, you will need to build the dependencies used for each helm chart.
You can run the following commands to do so:

```bash
cd charts/<chart>
helm dependency build
```
