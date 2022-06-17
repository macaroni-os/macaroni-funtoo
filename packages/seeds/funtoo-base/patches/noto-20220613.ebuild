# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit font

DESCRIPTION="Google's font family that aims to support all the world's languages"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlefonts/noto-fonts"

SRC_URI="https://github.com/googlefonts/noto-fonts/archive/71aff7a43636e36af59ace43433e531653ef1ac1.zip -> noto-fonts-20220613-71aff7a43636e36af59ace43433e531653ef1ac1.zip"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="*"

IUSE="cjk +extra"

RDEPEND="cjk? ( media-fonts/noto-cjk )"
DEPEND=""

RESTRICT="binchecks strip"

FILESDIR="${REPODIR}/media-fonts/noto-gen/files"

FONT_SUFFIX="ttf"
FONT_CONF=(
	# From ArchLinux
	"${FILESDIR}/66-noto-serif.conf"
	"${FILESDIR}/66-noto-mono.conf"
	"${FILESDIR}/66-noto-sans.conf"
)

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv ${WORKDIR}/noto-* ${S} || die
	fi
}

src_install() {
	mkdir install-unhinted install-hinted || die

	# FL-9036: Noto sometimes has colliding TTF file names
	# Passing `--backup=numbered` will force mv to succeed anyway, creating
	# "backup files" when it hits a collision, which we can later clean up.
	mv --backup=numbered unhinted/ttf/*/* install-unhinted/. ||  die
	mv --backup=numbered hinted/ttf/*/* install-hinted/. || die

	rm -rf install-unhinted/*~ install-hinted/*~

	FONT_S="${S}/install-unhinted/" font_src_install
	FONT_S="${S}/install-hinted/" font_src_install

	# Allow to drop some fonts optionally for people that want to save
	# disk space. Following ArchLinux options.
	use extra || rm -rf "${ED}"/usr/share/fonts/noto/Noto*{Condensed,SemiBold,Extra}*.ttf
}
