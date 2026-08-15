FROM alpine
RUN mkdir /eagle-minimal/etc/ /eagle-minimal/etc/anise -p && \
  cd /eagle-minimal/etc/ && ln -s anise luet
ADD conf/luet.yaml.docker.devel /eagle-minimal/etc/anise/anise.yaml
FROM macaronios/luet:latest-amd64

COPY --from=0 /eagle-minimal/ /
ENV USER=root

RUN [ \
  "/usr/bin/luet", "install", "-y", "--force", "--sync-repos", \
  "--cleanup", "--purge-repos", "--config", "/etc/anise/anise.yaml", \
  "repository/mark", \
  "repository/macaroni-commons", \
  "repository/macaroni-eagle"]

RUN [ \
  "/usr/bin/luet", "install", "-y", "--force", "--sync-repos", \
  "--cleanup", "--purge-repos", "--config", "/etc/anise/anise.yaml", \
  "--skip-config-protect", \
  "app-admin/entities", \
  "app-admin/anise", \
  "sys-apps/shadow", \
  "sys-apps/sed", \
  "app-shells/bash", \
  "glibc", \
  "gcc", \
  "sys-libs/ncurses", \
  "sys-apps/systemd", \
  "sys-apps/coreutils", \
  "sys-apps/iproute2", \
  "virtual/base", \
  "virtual-entities/base", \
  "app-admin/macaronictl-thin" ]

SHELL ["/bin/bash", "-c"]

RUN macaronictl env-update && \
  anise rm -y --nodeps virtual-entities/base && \
  anise cleanup --purge-repos

ENV TMPDIR=/tmp
ENTRYPOINT ["/bin/bash"]
