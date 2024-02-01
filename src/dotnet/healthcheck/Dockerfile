FROM ghcr.io/actions/actions-runner:2.312.0
# for latest release, see https://github.com/actions/runner/releases

USER root

# install curl and jq
RUN apt-get update && apt-get install -y curl jq unzip git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./scripts/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

ENV PATH="${PATH}:/home/runner/externals/node20/bin/"

USER runner

ENTRYPOINT ["./entrypoint.sh"]