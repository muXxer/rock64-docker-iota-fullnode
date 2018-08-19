FROM node:10-stretch

ARG REPO_NELSON_CLI=https://gitlab.com/semkodev/nelson.cli.git

WORKDIR /usr/src/
RUN git clone --depth=1 $REPO_NELSON_CLI
WORKDIR /usr/src/nelson.cli
RUN npm install -g

EXPOSE 16600
EXPOSE 18600

CMD ["/usr/local/bin/nelson"]
ENTRYPOINT ["/usr/local/bin/nelson"]
