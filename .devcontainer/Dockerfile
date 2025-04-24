FROM ghcr.io/containerbase/base:13.8.9@sha256:41b3e7db52a4f638d0f6c9241844d55dcaac465eed951b6e44c72edddeab780b

# Install Python
RUN apt-get update && apt-get install -y python3 python3-pip && apt-get clean

COPY tools/*.sh /usr/local/containerbase/tools/

# installs files to /etc/ct
# renovate: datasource=github-releases packageName=helm/chart-testing
RUN install-tool chart-testing v3.12.0

USER vscode

# renovate: datasource=github-releases packageName=kubernetes/kubernetes
RUN install-tool kubectl v1.32.3

# renovate: datasource=github-releases packageName=kubernetes-sigs/kind
RUN install-tool kind v0.27.0

# renovate: datasource=github-releases packageName=helm/helm
RUN install-tool helm v3.17.2

# renovate: datasource=github-releases packageName=norwoodj/helm-docs
RUN install-tool helm-docs 1.14.2

# renovate: datasource=github-releases packageName=instrumenta/kubeval
RUN install-tool kubeval v0.16.1