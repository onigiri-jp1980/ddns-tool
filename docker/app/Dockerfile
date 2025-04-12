

FROM python:3.12-slim

ARG CONTAINER_USER
ARG CONTAINER_UID
ARG CONTAINER_GID
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
 

#基本パッケージ準備＆poetryインストール

COPY ./docker/app/startup.sh /usr/local/bin/
RUN apt update && \
  apt upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt install -y curl sudo tzdata less awscli && \
  apt clean && \
  pip install --upgrade pip && \
  pip install poetry aws-sam-cli && \
  poetry config virtualenvs.create false && \
  adduser -u ${CONTAINER_UID} ${CONTAINER_USER} && \
  echo "${CONTAINER_USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${CONTAINER_USER} && \
  chmod +x /usr/local/bin/startup.sh

WORKDIR /app
USER ${CONTAINER_USER}
WORKDIR /app

COPY ./src/pyproject.toml /tmp
COPY ./src/poetry.lock /tmp
#COPY ./src/* /tmp
RUN cd /tmp && poetry install 
EXPOSE 8000