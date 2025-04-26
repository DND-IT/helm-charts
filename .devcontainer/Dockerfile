FROM ghcr.io/containerbase/base:13.8.17@sha256:24a4dd4ac98c5f9cedaaae344b84157106d9538f97720a48be4e652fc04fee07


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
