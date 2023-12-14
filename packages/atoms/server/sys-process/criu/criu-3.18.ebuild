# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit toolchain-funcs linux-info flag-o-matic python-r1

DESCRIPTION="Checkpoint and Restore in Userspace is a utility to checkpoint/restore Linux tasks"
HOMEPAGE="https://criu.org/"
SRC_URI="https://github.com/checkpoint-restore/criu/tarball/4c1a2ac41bb80843c927d2fde8f2ff4186f8d278 -> criu-3.18-4c1a2ac.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc selinux setproctitle static-libs -video_cards_amdgpu"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-libs/protobuf-c
	dev-libs/libnl:3
	net-libs/libnet:1.1
	sys-libs/libcap
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

	# Disabling criu amdgpu plugin temporarily
	# There is an upstream bug breaking the amdgpu plugin compilation: https://github.com/checkpoint-restore/criu/issues/1877
	# Also reference https://bugs.funtoo.org/browse/FL-9805 for more details and analysis
	# Once the upstream bug is fixed, the if loop encasing the sed statements can be enabled for testing
	#if ! use video_cards_amdgpu; then
	sed \
		-e 's:pkg-config-check,libdrm:pkg-config-check,no_libdrm:g' \
		-i Makefile.config || die

	sed \
		-e 's:install-compel install-amdgpu_plugin:install-compel:g' \
		-i Makefile.install || die
	#fi

	use doc || sed -i 's_\(install: \)install-man _\1_g' Makefile.install
}

src_configure() {
	# Gold linker generates invalid object file when used with criu's custom
	# linker script.  Use the bfd linker instead. See https://crbug.com/839665#c3
	tc-ld-disable-gold

	# Build system uses this variable as a trigger to append coverage flags
	# we'd like to avoid it. https://bugs.gentoo.org/744244
	unset GCOV

	python_setup
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
}

src_test() {
	# root privileges are required to dump all necessary info
	if [[ ${EUID} -eq 0 ]] ; then
		emake -j1 CC="$(tc-getCC)" ARCH="$(criu_arch)" V=1 WERROR=0 test
	fi
}

install_crit() {
	local -x \
		CRIU_VERSION_MAJOR="$(ver_cut 1)" \
		CRIU_VERSION_MINOR=$(ver_cut 2) \
		CRIU_VERSION_SUBLEVEL=$(ver_cut 3)

	python_optimize
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

	python_foreach_impl install_crit

	if ! use static-libs; then
		find "${D}" -name "*.a" -delete || die
	fi
}
