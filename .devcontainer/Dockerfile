FROM ghcr.io/containerbase/base:9.28.0@sha256:6273193cb55945e8d7a9154829497584558094cc9e11481fd48c41dfc8920325

COPY tools/*.sh /usr/local/containerbase/tools/

# renovate: datasource=github-releases depName=docker packageName=moby/moby
ARG DOCKER_VERSION=v24.0.9
RUN install-tool docker

# renovate: datasource=github-releases depName=kubectl packageName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.30.0
RUN install-tool kubectl

# renovate: datasource=github-releases depName=kind packageName=kubernetes-sigs/kind
ARG KIND_VERSION=v0.22.0
RUN install-tool kind

# renovate: datasource=github-releases depName=helm packageName=helm/helm
ARG HELM_VERSION=v3.14.4
RUN install-tool helm

# renovate: datasource=github-releases depName=chart-testing packageName=helm/chart-testing
ARG CHART_TESTING_VERSION=v3.10.1
RUN install-tool chart-testing

# renovate: datasource=github-releases depName=helm-docs packageName=norwoodj/helm-docs
ARG HELM_DOCS_VERSION=1.13.1
RUN install-tool helm-docs

# renovate: datasource=github-releases depName=kubeval packageName=instrumenta/kubeval
ARG KUBEVAL_VERSION=v0.16.1
RUN install-tool kubeval
