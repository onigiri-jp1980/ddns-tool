FROM python:3.12-slim

ARG CONTAINER_USER
ARG CONTAINER_UID
ARG CONTAINER_GID
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

#基本パッケージ準備＆poetryインストール
RUN apt update && \
  apt upgrade && \
  DEBIAN_FRONTEND=noninteractive apt install -y sudo tzdata && \
  apt clean && \
  pip install --upgrade pip && \
  pip install poetry && \
  poetry config virtualenvs.create false && \
  adduser -u ${CONTAINER_UID} ${CONTAINER_USER} && \
  echo "${CONTAINER_USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${CONTAINER_USER} && \
  pip install poetry 

WORKDIR /app
USER ${CONTAINER_USER}

EXPOSE 8000