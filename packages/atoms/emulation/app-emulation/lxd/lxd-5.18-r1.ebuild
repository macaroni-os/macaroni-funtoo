# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools golang-base bash-completion-r1 linux-info user

DESCRIPTION="Fast, dense and secure container management"
HOMEPAGE="https://linuxcontainers.org/lxd/introduction/ https://github.com/lxc/lxd"
SRC_URI="https://github.com/canonical/lxd/releases/download/lxd-${PV}/lxd-${PV}.tar.gz"
#SRC_URI="https://github.com/canonical/lxd/archive/refs/tags/lxd-${PV}.tar.gz"

# Needs to include licenses for all bundled programs and libraries.
LICENSE="Apache-2.0 BSD BSD-2 LGPL-3 MIT MPL-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="apparmor ipv6 nls"

DEPEND="app-arch/xz-utils
	app-arch/lz4
	>=app-emulation/lxc-4.0.6[apparmor?]
	dev-lang/tcl
	dev-libs/libuv
	dev-libs/lzo
	>=dev-util/xdelta-3.0
	net-dns/dnsmasq[dhcp,ipv6?]"
RDEPEND="${DEPEND}
	net-firewall/ebtables
	net-firewall/iptables[ipv6?]
	sys-apps/iproute2[ipv6?]
	sys-fs/fuse:*
	sys-fs/lxcfs
	sys-fs/squashfs-tools[lzma]
	virtual/acl"
BDEPEND=">=dev-lang/go-1.18
	>=sys-kernel/linux-headers-4.15
	nls? ( sys-devel/gettext )"

CONFIG_CHECK="
	~CGROUPS
	~IPC_NS
	~NET_NS
	~PID_NS

	~SECCOMP
	~USER_NS
	~UTS_NS
"

ERROR_IPC_NS="CONFIG_IPC_NS is required."
ERROR_NET_NS="CONFIG_NET_NS is required."
ERROR_PID_NS="CONFIG_PID_NS is required."
ERROR_SECCOMP="CONFIG_SECCOMP is required."
ERROR_UTS_NS="CONFIG_UTS_NS is required."

# Go magic.
QA_PREBUILT="/usr/lib/lxd/libdqlite.so.0.0.1
	/usr/bin/fuidshift
	/usr/bin/lxc
	/usr/bin/lxc-to-lxd
	/usr/bin/lxd-agent
	/usr/bin/lxd-benchmark
	/usr/bin/lxd-migrate
	/usr/bin/lxd-user
	/usr/sbin/lxd"

RESTRICT="test"
VDIR="${S}/vendor"

src_prepare() {
	default

	sed -i \
		-e "s:\./configure:./configure --prefix=/usr --libdir=${EPREFIX}/usr/lib/lxd:g" \
		-e "s:make:make ${MAKEOPTS}:g" \
		Makefile || die

	sed -i 's#zfs version 2>/dev/null | cut -f 2 -d - | head -1#< /sys/module/zfs/version cut -f 1#' ${VDIR}/raft/configure.ac || die

	# Fix hardcoded ovmf file path, see bug Gentoo 763180
	sed -i \
		-e "s:/usr/share/OVMF:/usr/share/edk2-ovmf:g" \
		-e "s:OVMF_VARS.ms.fd:OVMF_VARS.secboot.fd:g" \
		doc/environment.md \
		lxd/apparmor/instance_qemu.go \
		lxd/instance/drivers/driver_qemu.go || die "Failed to fix hardcoded ovmf paths."

	cd ${VDIR}/dqlite
	eautoreconf

	cd ${VDIR}/raft
	eautoreconf
}

src_configure() {
	export RAFT_CFLAGS="-I${VDIR}/raft/include/"
	export RAFT_LIBS="${VDIR}/raft/.libs"

	cd ${VDIR}/raft
	econf --libdir="${EPREFIX}"/usr/lib/lxd

	cd ${VDIR}/dqlite
	export PKG_CONFIG_PATH="${VDIR}/raft"
	econf --libdir="${EPREFIX}"/usr/lib/lxd
}

src_compile() {
	export GOFLAGS="-buildmode=pie -trimpath -mod=vendor"
	#export CGO_LDFLAGS_ALLOW="(-Wl,-wrap,pthread_create)|(-Wl,-z,now)"
	export CGO_LDFLAGS_ALLOW="-Wl,-z,now"

	export CGO_CFLAGS="${CGO_CFLAGS} -I${VDIR}/dqlite/include/ -I${VDIR}/raft/include/"
	export CGO_LDFLAGS="${CGO_LDFLAGS} -L${VDIR}/raft/.libs/ -L${VDIR}/dqlite/.libs/ -Wl,-rpath,${EPREFIX}/usr/lib/lxd"
	export LD_LIBRARY_PATH="${VDIR}/raft/.libs/:${VDIR}/dqlite/.libs/:${LD_LIBRARY_PATH}"

	cd ${VDIR}/raft || die
	emake

	cd ${VDIR}/dqlite || die
	emake CFLAGS="-I${VDIR}/raft/include" LDFLAGS="-L${VDIR}/raft/.libs -lraft"

	cd ${S}/ || die
	mkdir -p bin || die

	export GOFLAGS="-buildmode=pie -trimpath -mod=vendor"
	export CGO_LDFLAGS_ALLOW="(-Wl,-wrap,pthread_create)|(-Wl,-z,now)"

	CGO_ENABLED=0 go build -v -x -tags lxd-metadata -o bin/ ./lxd/lxd-metadata/... || die "Failed to build lxd-metadata"

	CGO_ENABLED=0 go build $GOFLAGS -v -x -tags "netgo" -o bin/ ./lxd-migrate/... || die "Failed to build lxd-migrate"

	for k in fuidshift lxc lxc-to-lxd lxd lxd-benchmark lxd-user; do
		CGO_ENABLED=1 go build -v -x -tags "libsqlite3" -o bin/ ./${k}/... || die "Failed to build ${k}"
	done

	CGO_ENABLED=0 CGO_LDFLAGS="$CGO_LDFLAGS -static" go build -v -x -tags "agent,netgo" -o bin/ ./lxd-agent/... || die "Failed to build lxd-agent"

	use nls && emake build-mo
}

src_install() {
	cd ${S}/
	local bindir="bin"

	dosbin ${bindir}/lxd

	for l in fuidshift lxd-agent lxd-benchmark lxd-migrate lxc lxc-to-lxd lxd-user lxd-metadata; do
		dobin ${bindir}/${l}
	done

	for m in dqlite raft; do
		local mdir=${VDIR}/${m}
		cd ${mdir} || die "failed switching into /${mdir}"
		emake DESTDIR="${D}" install
	done

	cd "${S}" || die

	# We only need bundled libs during src_compile, and we don't want anything
	# to link against these.
	rm -r "${ED}"/usr/include || die
	rm -r "${ED}"/usr/lib/lxd/*.a || die
	rm -r "${ED}"/usr/lib/lxd/pkgconfig || die

	newbashcomp scripts/bash/lxd-client lxc
	bashcomp_alias lxc lxd.lxc

	newinitd "${FILESDIR}"/5.x/lxd.initd lxd || die
	newconfd "${FILESDIR}"/5.x/lxd.confd lxd || die

	local dodoc_opts=-r
	dodoc -r AUTHORS doc/**
	use nls && domo po/*.mo
}

pkg_postinst() {
	if [[ -z ${ROOT} && -n "$( rc-service lxd status| grep started )"  ]]; then
		einfo "Restarting lxd service."
		if nofatal rc-service lxd restart ; then
			eerror
			eerror "LXD service failed to start after update."
			eerror "Please check if your configuration for ${REPLACING_VERSIONS}"
			eerror "is still valid for the new version."
			eerror
		else
			ewarn
			ewarn "LXD service was automatically restarted."
			ewarn "If you are unable to 'lxc exec <containername>',"
			ewarn "then you may need to restart all containers. "
			ewarn "This can be done with /etc/init.d/lxd stop; /etc/init.d/lxd start."
			ewarn
		fi
	fi

	elog
	elog "Consult https://www.funtoo.org/LXD for more information,"
	elog "including a Quick Start."

	# The control socket will be owned by (and writeable by) this group.
	enewgroup lxd

	elog
	elog "Please run 'lxc-checkconfig' to see all optional kernel features."
	elog
	elog "Though not strictly required, some features are enabled at run-time"
	elog "when the relevant helper programs are detected:"
	elog "- sys-fs/btrfs-progs"
	elog "- sys-fs/lvm2"
	elog "- sys-fs/zfs"
	elog "- sys-process/criu"
	elog
	elog "Be sure to add your local user to the lxd group."
}
