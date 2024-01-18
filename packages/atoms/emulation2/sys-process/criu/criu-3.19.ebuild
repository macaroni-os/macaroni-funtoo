# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517=setuptools
inherit toolchain-funcs linux-info flag-o-matic distutils-r1

DESCRIPTION="Checkpoint/Restore tool"
HOMEPAGE="https://criu.org/"
SRC_URI="https://github.com/checkpoint-restore/criu/tarball/f8b14286b092853a4485813e1efd564109df9123 -> criu-3.19-f8b1428.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="bpf doc selinux setproctitle static-libs -video_cards_amdgpu"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-libs/protobuf-c
	dev-libs/libnl:3
	net-libs/libnet:1.1
	sys-libs/libcap
	bpf? ( dev-libs/libbpf:= )
	selinux? ( sys-libs/libselinux )
	setproctitle? ( dev-libs/libbsd )
	video_cards_amdgpu? ( x11-libs/libdrm[video_cards_amdgpu?] )"
DEPEND="${RDEPEND}
	doc? (
		app-text/asciidoc
		app-text/xmlto
	)"
RDEPEND="${RDEPEND}
	dev-python/protobuf-python[${PYTHON_USEDEP}]
"

CONFIG_CHECK="~CHECKPOINT_RESTORE ~NAMESPACES ~PID_NS ~FHANDLE ~EVENTFD ~EPOLL ~INOTIFY_USER
	~UNIX_DIAG ~INET_DIAG ~INET_UDP_DIAG ~PACKET_DIAG ~NETLINK_DIAG ~TUN ~NETFILTER_XT_MARK"

# root access required for tests
RESTRICT="test"

criu_arch() {
	# criu infers the arch from $(uname -m).  We never want this to happen.
	case ${ARCH} in
		amd64) echo "x86";;
		arm64) echo "aarch64";;
		ppc64*) echo "ppc64";;
		*)     echo "${ARCH}";;
	esac
}

post_src_unpack() {
	if [ ! -d ${S} ]; then
		mv ${WORKDIR}/checkpoint-restore-criu* ${S} || die
	fi
}

pkg_setup() {
	use amd64 && CONFIG_CHECK+=" ~IA32_EMULATION"
	linux-info_pkg_setup
}

src_prepare() {
	default

	if ! use selinux; then
		sed \
			-e 's:libselinux:no_libselinux:g' \
			-i Makefile.config || die
	fi

	if ! use bpf; then
		sed \
			-e 's:libbpf:no_libbpf:g' \
			-i Makefile.config || die
	fi

	# Disabling criu amdgpu plugin temporarily
	# There is an upstream bug breaking the amdgpu plugin compilation: https://github.com/checkpoint-restore/criu/issues/1877
	# Also reference https://bugs.funtoo.org/browse/FL-9805 for more details and analysis
	# Once the upstream bug is fixed, the if loop encasing the sed statements can be enabled for testing
	if ! use video_cards_amdgpu; then
	sed \
		-e 's:pkg-config-check,libdrm:pkg-config-check,no_libdrm:g' \
		-i Makefile.config || die

	sed \
		-e 's:install-compel install-amdgpu_plugin:install-compel:g' \
		-i Makefile.install || die
	fi

	use doc || sed -i 's_\(install: \)install-man _\1_g' Makefile.install
	distutils-r1_src_prepare
}

src_configure() {
	# Gold linker generates invalid object file when used with criu's custom
	# linker script.  Use the bfd linker instead. See https://crbug.com/839665#c3
	tc-ld-disable-gold

	# Build system uses this variable as a trigger to append coverage flags
	# we'd like to avoid it. https://bugs.gentoo.org/744244
	unset GCOV

	python_setup
	pushd crit >/dev/null || die
	local -x \
		CRIU_VERSION_MAJOR="$(ver_cut 1)" \
		CRIU_VERSION_MINOR=$(ver_cut 2) \
		CRIU_VERSION_SUBLEVEL=$(ver_cut 3)
	distutils-r1_src_configure
	popd >/dev/null || die
}

src_compile() {
	local target="all $(usex doc 'docs' '')"
	emake \
		HOSTCC="$(tc-getBUILD_CC)" \
		CC="$(tc-getCC)" \
		LD="$(tc-getLD)" \
		AR="$(tc-getAR)" \
		PYTHON="${EPYTHON%.?}" \
		FULL_PYTHON="${PYTHON%.?}" \
		OBJCOPY="$(tc-getOBJCOPY)" \
		LIBDIR="${EPREFIX}/usr/$(get_libdir)" \
		ARCH="$(criu_arch)" \
		V=1 WERROR=0 DEBUG=0 \
		SETPROCTITLE=$(usex setproctitle) \
		${target}

	pushd crit >/dev/null || die
	local -x \
		CRIU_VERSION_MAJOR="$(ver_cut 1)" \
		CRIU_VERSION_MINOR=$(ver_cut 2) \
		CRIU_VERSION_SUBLEVEL=$(ver_cut 3)
	distutils-r1_src_compile
	popd >/dev/null || die
}

src_test() {
	# root privileges are required to dump all necessary info
	if [[ ${EUID} -eq 0 ]] ; then
		emake -j1 CC="$(tc-getCC)" ARCH="$(criu_arch)" V=1 WERROR=0 test
	fi
}

python_install() {
	local -x \
		CRIU_VERSION_MAJOR="$(ver_cut 1)" \
		CRIU_VERSION_MINOR=$(ver_cut 2) \
		CRIU_VERSION_SUBLEVEL=$(ver_cut 3)

	distutils-r1_python_install
}


src_install() {
	emake \
		ARCH="$(criu_arch)" \
		PREFIX="${EPREFIX}"/usr \
		PYTHON="${EPYTHON%.?}" \
		FULL_PYTHON="${PYTHON%.?}" \
		LOGROTATEDIR="${EPREFIX}"/etc/logrotate.d \
		DESTDIR="${D}" \
		LIBDIR="${EPREFIX}/usr/$(get_libdir)" \
		V=1 WERROR=0 DEBUG=0 \
		install

	use doc && dodoc CREDITS README.md

	pushd crit >/dev/null || die
	distutils-r1_src_install
	popd >/dev/null || die

	if ! use static-libs; then
		find "${D}" -name "*.a" -delete || die
	fi
}
