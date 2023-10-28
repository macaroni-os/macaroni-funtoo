FROM alpine
RUN mkdir /funtoo-minimal/etc/ -p
FROM macaronios/luet:latest-amd64
ADD conf/luet.yaml.docker /etc/luet/luet.yaml
#COPY luet /usr/bin/luet
#ADD https://raw.githubusercontent.com/geaaru/luet-specs/master/contrib/geaaru.yml /etc/luet/repos.conf.d/

COPY --from=0 /funtoo-minimal/ /
ENV USER=root

SHELL ["/usr/bin/luet", "install", "-y", "--force", "--sync-repos"]
RUN repository/mottainai-stable
RUN repository/macaroni-commons
RUN repository/macaroni-phoenix

RUN system/entities

SHELL ["/usr/bin/luet", "install", "-y", "--force"]

RUN system/luet-geaaru-thin
RUN sys-apps/shadow
RUN sys-apps/sed
RUN app-shells/bash
RUN gcc

RUN virtual-entities/base

SHELL ["/bin/bash", "-c"]

RUN luet i -y iproute2 sysvinit coreutils sys-apps/openrc virtual/base macaronictl-thin --skip-config-protect && \
  macaronictl env-update && \
  luet cleanup --purge-repos && \
  mkdir /tmp

ENV TMPDIR=/tmp
ENTRYPOINT ["/bin/bash"]
