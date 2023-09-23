# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DEBIAN_PATCH_VERSION="11.2-9"

DESCRIPTION="Console based chess interface"
HOMEPAGE="http://sjeng.sourceforge.net/"
SRC_URI="mirror://sourceforge/sjeng/Sjeng-Free-${PV}.tar.gz
	mirror://debian/pool/main/s/sjeng/sjeng_${DEBIAN_PATCH_VERSION}.debian.tar.xz
"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

RDEPEND="sys-libs/gdbm:0="
DEPEND=${RDEPEND}

PATCHES=(
#	"${WORKDIR}/sjeng_${DEBIAN_PATCH_VERSION}.diff"
	"${WORKDIR}/debian/patches"
)

S="${WORKDIR}/Sjeng-Free-${PV}"

src_prepare() {
	default

	#hprefixify book.c rcfile.c

	# Files generated with ancient autotools, regenerate to respect CC.
	mv configure.{in,ac} || die
	eautoreconf
}

src_install() {
	default

	insinto /etc
	doins sjeng.rc

	insinto /usr/share/games/sjeng
	doins books/*.opn
}
