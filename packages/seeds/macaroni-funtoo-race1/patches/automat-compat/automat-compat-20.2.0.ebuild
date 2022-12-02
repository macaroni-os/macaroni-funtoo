# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION=""
HOMEPAGE="https://github.com/glyph/Automat https://pypi.org/project/Automat/"
SRC_URI="https://files.pythonhosted.org/packages/80/c5/82c63bad570f4ef745cc5c2f0713c8eddcd07153b4bee7f72a8dc9f9384b/Automat-20.2.0.tar.gz -> Automat-20.2.0.tar.gz
"

DEPEND=""
RDEPEND="!<dev-python/automat-22.10.0 "
IUSE=""
SLOT="0"
LICENSE="MIT"
KEYWORDS="*"
S="${WORKDIR}/automat-20.2.0"

post_src_install() {
	rm -rf ${D}/usr/bin
}