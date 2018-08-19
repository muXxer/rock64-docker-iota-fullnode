FROM node:10-stretch

ARG REPO_FIELD_CLI=https://gitlab.com/semkodev/field.cli.git

WORKDIR /usr/src/
RUN git clone --depth=1 $REPO_FIELD_CLI
WORKDIR /usr/src/field.cli
RUN npm install -g

EXPOSE 21310

CMD ["/usr/local/bin/field"]
ENTRYPOINT ["/usr/local/bin/field"]
