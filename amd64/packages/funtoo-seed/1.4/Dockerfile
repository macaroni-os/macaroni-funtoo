FROM scratch

LABEL maintainer="geaaru <geaaru@sabayonlinux.org>"

ARG TARBALL=local
ENV TARBALL ${TARBALL}
ADD ${TARBALL} /

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.utf8
ENV TERM=linux

CMD ["/bin/bash"]
