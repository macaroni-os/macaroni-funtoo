# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info toolchain-funcs udev tmpfiles

DESCRIPTION="Device mapper target autoconfig"
HOMEPAGE="http://christophe.varoqui.free.fr/"
SRC_URI="https://github.com/opensvc/multipath-tools/tarball/3daacfdfd110b24a3a7d5a276dcf8512b7039199 -> multipath-tools-0.9.8-3daacfd.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	dev-libs/json-c:=
	dev-libs/libaio
	dev-libs/userspace-rcu:=
	>=sys-fs/lvm2-2.02.45
	>=virtual/libudev-232
	sys-libs/readline:="
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

CONFIG_CHECK="~DM_MULTIPATH"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv opensvc-multipath-tools* "${S}" || die
	fi
}

src_prepare() {
	default

	sed -r -i -e '/^(CPPFLAGS|CFLAGS)\>/s,^(CPPFLAGS|CFLAGS)\>[[:space:]]+:=,\1 := $(GENTOO_\1),' \
		"${S}"/Makefile.inc || die
}

src_compile() {
	tc-export CC

	# LIBDM_API_FLUSH involves grepping files in /usr/include,
	# so force the test to go the way we want #411337.
	emake \
		prefix="${EPREFIX}/usr" \
		LIB="$(get_libdir)" \
		LIBDM_API_FLUSH=1 \
		PKGCONFIG="$(tc-getPKG_CONFIG)" \
		GENTOO_CFLAGS="${CFLAGS}" \
		GENTOO_CPPFLAGS="${CPPFLAGS}" \
		FAKEVAR=1
}

src_install() {
	dodir /sbin

	# Please clean this up > 0.9.3: https://github.com/opensvc/multipath-tools/pull/53
	# $(prefix) doesn't work correctly in makefile in 0.9.3.
	emake \
		DESTDIR="${ED}" \
		prefix="${EPREFIX}" \
		LIB="$(get_libdir)" \
		RUN=run \
		libudevdir="${EPREFIX}/$(get_udevdir)" \
		pkgconfdir="${EPREFIX}/usr/$(get_libdir)/pkgconfig" \
		GENTOO_CFLAGS="${CFLAGS}" \
		GENTOO_CPPFLAGS="${CPPFLAGS}" \
		install

	einstalldocs

	newinitd "${FILESDIR}"/multipathd-r1.rc multipathd
	newinitd "${FILESDIR}"/multipath.rc multipath

	find "${ED}" -type f -name '*.la' -delete || die
}

pkg_postinst() {
	tmpfiles_process /usr/lib/tmpfiles.d/multipath.conf
	udev_reload

	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		elog "If you need multipath on your system, you must"
		elog "add 'multipath' into your boot runlevel!"
	fi
}

pkg_postrm() {
	udev_reload
}
