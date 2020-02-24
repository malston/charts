# FROM gcr.io/kubernetes-charts-ci/test-image:v3.4.0
FROM quay.io/helmpack/chart-testing:v3.0.0-beta.1

ARG pivnet_token
ENV PIVNET_TOKEN $pivnet_token

ARG pks_version
ENV PKS_VERSION ${pks_version:-1.6.1}

ARG pivnet_version
ENV PIVNET_VERSION ${pivnet_version:-1.0.0}

ADD https://github.com/pivotal-cf/pivnet-cli/releases/download/v$PIVNET_VERSION/pivnet-linux-amd64-$PIVNET_VERSION .
RUN chmod +x pivnet-linux-amd64-$PIVNET_VERSION && mv pivnet-linux-amd64-$PIVNET_VERSION /usr/bin/pivnet

RUN pivnet login --api-token $PIVNET_TOKEN

RUN pivnet download-product-files -p pivotal-container-service -r $PKS_VERSION -g "pks-linux-amd64*" && \
	chmod +x pks* && mv pks-linux-* /usr/local/bin/pks

