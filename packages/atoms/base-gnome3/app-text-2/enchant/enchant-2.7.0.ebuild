# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit libtool autotools vala

DESCRIPTION="Spellchecker wrapping library"
HOMEPAGE="https://abiword.github.io/enchant/"
SRC_URI="https://github.com/AbiWord/enchant/releases/download/v2.7.0/enchant-2.7.0.tar.gz -> enchant-2.7.0.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="2"
KEYWORDS="*"

IUSE="aspell +hunspell nuspell test voikko"
RESTRICT="!test? ( test )"
REQUIRED_USE="|| ( aspell hunspell nuspell )"

COMMON_DEPEND="
	>=dev-libs/glib-2.6:2
	aspell? ( app-text/aspell )
	hunspell? ( >=app-text/hunspell-1.2.1:0= )
	nuspell? ( >=app-text/nuspell-5.1.0:0= )
	voikko? ( dev-libs/libvoikko )
"
RDEPEND="${COMMON_DEPEND}
	!<app-text/enchant-${PV}:2.2
"
DEPEND="${COMMON_DEPEND}
	test? ( >=dev-libs/unittest++-2.0.0-r2 )
"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	sed -e 's|0.56|0.54|g' -i configure.ac
	default
	elibtoolize
	eautoconf
	vala_src_prepare
}

src_configure() {
	local myconf=(
		--disable-static
		--enable-relocatable
		$(use_with aspell)
		$(use_with hunspell)
		$(use_with nuspell)
		$(use_with voikko)
		--without-hspell
		--without-applespell
		--without-zemberek
		--with-hunspell-dir="${EPREFIX}"/usr/share/hunspell/
	)
	econf "${myconf[@]}"
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
