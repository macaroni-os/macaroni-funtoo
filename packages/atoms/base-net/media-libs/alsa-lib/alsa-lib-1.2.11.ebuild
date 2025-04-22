# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit autotools python-single-r1

DESCRIPTION="Advanced Linux Sound Architecture Library"
HOMEPAGE="https://alsa-project.org/"
SRC_URI="https://www.alsa-project.org/files/pub/lib/alsa-lib-1.2.11.tar.bz2 -> alsa-lib-1.2.11.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="alisp debug doc elibc_uclibc python +thread-safety"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

BDEPEND="doc? ( >=app-doc/doxygen-1.2.6 )"
RDEPEND="python? ( ${PYTHON_DEPS} )
	media-libs/alsa-topology-conf
	media-libs/alsa-ucm-conf
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-1.1.6-missing_files.patch" #652422
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	find . -name Makefile.am -exec sed -i -e '/CFLAGS/s:-g -O2::' {} + || die
	# https://bugs.gentoo.org/509886
	if use elibc_uclibc ; then
		sed -i -e 's:oldapi queue_timer:queue_timer:' test/Makefile.am || die
	fi
	# https://bugs.gentoo.org/545950
	sed -i -e '5s:^$:\nAM_CPPFLAGS = -I$(top_srcdir)/include:' test/lsb/Makefile.am || die
	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-maintainer-mode
		--disable-resmgr
		--enable-aload
		--enable-rawmidi
		--enable-seq
		--enable-shared
		$(use_enable python)
		$(use_enable alisp)
		$(use_enable thread-safety)
		$(use_with debug)
		$(usex elibc_uclibc --without-versioned '')
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_compile() {
	emake
	if use doc; then
		emake doc
		grep -FZrl "${S}" doc/doxygen/html | xargs -0 sed -i -e "s:${S}::" || die
	fi
}

src_install() {
	use doc && local HTML_DOCS=( doc/doxygen/html/. )
	default
}
