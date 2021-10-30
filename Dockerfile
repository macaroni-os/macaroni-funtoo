FROM quay.io/mocaccino/extra
RUN mkdir /funtoo-minimal/etc/ -p && \
      touch /funtoo-minimal/etc/passwd && \
      touch /funtoo-minimal/etc/shadow && \
      touch /funtoo-minimal/etc/group && \
      touch /funtoo-minimal/etc/gshadow

FROM quay.io/luet/base:develop
ADD conf/luet.yaml.docker /etc/luet/luet.yaml
COPY luet /usr/bin/luet
#ADD https://raw.githubusercontent.com/geaaru/luet-specs/master/contrib/geaaru.yml /etc/luet/repos.conf.d/

COPY --from=0 /funtoo-minimal/ /
ENV USER=root

SHELL ["/usr/bin/luet", "install", "-y"]
RUN repository/luet
RUN repository/geaaru-stable
RUN repository/mocaccino-os-commons
RUN repository/mocaccino-extra
RUN repository/mocaccino-funtoo

RUN system/entities
RUN pkglist/funtoo-base

SHELL ["entities", "merge", "-a", "-s"]
RUN /usr/share/mocaccino/layers/funtoo-base/entities/

SHELL ["/usr/bin/luet", "install", "-y", "-d"]

#RUN system/luet
RUN sys-apps/shadow
RUN sys-apps/sed
RUN app-shells/bash
RUN sys-devel-9.2.0/gcc


RUN sys-apps/iproute2
RUN sys-libs/readline
RUN sys-apps/sysvinit

RUN sys-apps/coreutils
RUN sys-apps/openrc

SHELL ["/bin/bash", "-c"]

RUN rm -rf /var/cache/luet/packages/ /var/cache/luet/repos/ && \
  luet uninstall -y pkglist/funtoo-base

ENV TMPDIR=/tmp
ENTRYPOINT ["/bin/bash"]
