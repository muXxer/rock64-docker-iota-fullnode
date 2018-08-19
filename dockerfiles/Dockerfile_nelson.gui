FROM node:10-stretch

ARG REPO_NELSON_GUI=https://gitlab.com/semkodev/nelson.gui.git

WORKDIR /usr/src/
RUN git clone --depth=1 $REPO_NELSON_GUI
WORKDIR /usr/src/nelson.gui
RUN npm install -g yarn \
    && yarn install --pure-lockfile \
    && yarn run build:all \
    && npm install -g . \
    && npm uninstall -g yarn

EXPOSE 5000

CMD ["/usr/local/bin/nelson.gui"]
ENTRYPOINT ["/usr/local/bin/nelson.gui"]
