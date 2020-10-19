FROM node:14.14.0-buster-slim

LABEL maintainer "Daisuke Miyamoto <miyamoto.daisuke@classmethod.jp>"


###############################################################################
## setup

ENV DEBCONF_NOWARNINGS yes
RUN apt-get clean \
  && apt-get update \
  && apt-get install -y locales \
  && locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8

###############################################################################
# install Java 8 (for PlantUML, RedPen)

# 参考: https://qiita.com/PINTO/items/612718c0ce4f1def6c6e
RUN mkdir -p /usr/share/man/man1 \
  && apt-get -y -qq install \
  apt-transport-https \
  ca-certificates \
  wget \
  dirmngr \
  gnupg \
  software-properties-common \
  && wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
  && add-apt-repository 'deb https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ buster main' \
  && apt-get -y -qq update \
  && apt-get -y -qq install adoptopenjdk-8-hotspot\
  && add-apt-repository --remove 'deb https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ buster main' \
  && update-java-alternatives --jre-headless --jre --set adoptopenjdk-8-hotspot-amd64

###############################################################################
# install AWS CLI (for deploy)

RUN apt-get install -y -qq python3-pip \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && python -m pip install -U pip \
  && pip3 install awscli==1.18.218

###############################################################################
# install git

RUN apt-get update \
    && apt-get install -y git

###############################################################################
# install mkdocs

RUN pip3 install mkdocs \
  && pip3 install mkdocs-material \
  && pip3 install mkpdfs-mkdocs \
  && pip3 install plantuml-markdown \
  && pip3 install fontawesome_markdown

###############################################################################
# install markdownlint

RUN npm install -g markdownlint-cli@0.26.0

###############################################################################
# install RedPen

ENV REDPEN_VERSION 1.10.4

RUN wget -nv -O - https://github.com/redpen-cc/redpen/releases/download/redpen-${REDPEN_VERSION}/redpen-${REDPEN_VERSION}.tar.gz | tar zx -C /opt
ENV PATH $PATH:/opt/redpen-distribution-${REDPEN_VERSION}/bin

###############################################################################
# install textlint

RUN npm install -g \
    textlint@11.8.2 \
    textlint-rule-no-todo@2.0.1 \
    textlint-rule-no-start-duplicated-conjunction@2.0.2 \
    textlint-rule-prh@5.3.0 \
    textlint-rule-max-number-of-lines@1.0.3 \
    textlint-rule-max-comma@1.0.4 \
    textlint-rule-no-exclamation-question-mark@1.1.0 \
    textlint-rule-no-dead-link@4.7.0 \
    textlint-rule-editorconfig@1.0.3 \
    textlint-rule-no-empty-section@1.1.0 \
    textlint-rule-date-weekday-mismatch@1.0.5 \
    textlint-rule-terminology@2.1.5 \
    textlint-rule-period-in-list-item@0.3.2 \
    textlint-rule-no-nfd@1.0.2 \
    textlint-rule-no-surrogate-pair@1.0.1 \
    textlint-rule-common-misspellings@1.0.1 \
    textlint-rule-max-ten@2.0.4 \
    textlint-rule-max-kanji-continuous-len@1.1.1 \
    textlint-rule-spellcheck-tech-word@5.0.0 \
    textlint-rule-web-plus-db@1.1.5 \
    textlint-rule-no-mix-dearu-desumasu@4.0.1 \
    textlint-rule-no-doubled-joshi@3.8.0 \
    textlint-rule-no-double-negative-ja@1.0.6 \
    textlint-rule-no-hankaku-kana@1.0.2 \
    textlint-rule-ja-no-weak-phrase@1.0.5 \
    textlint-rule-ja-no-redundant-expression@3.0.2 \
    textlint-rule-ja-no-abusage@2.0.1 \
    textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet@1.0.1 \
    textlint-rule-sentence-length@2.2.0 \
    textlint-rule-no-dropping-the-ra@2.0.0 \
    textlint-rule-no-doubled-conjunctive-particle-ga@1.1.1 \
    textlint-rule-no-doubled-conjunction@1.0.3 \
    textlint-rule-ja-no-mixed-period@2.1.1 \
    textlint-rule-ja-yahoo-kousei@1.0.3 \
    textlint-rule-max-appearence-count-of-words@1.0.1 \
    textlint-rule-max-length-of-title@1.0.1 \
    textlint-rule-incremental-headers@0.2.0 \
    textlint-rule-ja-unnatural-alphabet@2.0.1 \
    @textlint-ja/textlint-rule-no-insert-dropping-sa@1.0.1 \
    textlint-rule-preset-ja-technical-writing@4.0.1 \
    textlint-rule-preset-jtf-style@2.3.6 \
    textlint-rule-preset-ja-spacing@2.0.2 \
    textlint-rule-preset-japanese@5.0.0 \
    textlint-filter-rule-allowlist@2.0.1 \
    textlint-filter-rule-comments@1.2.2 \
    textlint-filter-rule-node-types@1.1.0

###############################################################################
# install Japanese font (for PDF)

RUN apt-get install -y -qq fonts-migmix


###############################################################################
# install graphviz (for PlantUML)

RUN apt-get install -y -qq graphviz


###############################################################################
# install Caribre (for PDF)

ENV CALIBRE_INSTALLER_SOURCE_CODE_URL https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py

RUN wget -O - ${CALIBRE_INSTALLER_SOURCE_CODE_URL} | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)"
ENV PATH $PATH:/opt/calibre


###############################################################################
# clean up

RUN apt-get clean && apt-get autoremove
