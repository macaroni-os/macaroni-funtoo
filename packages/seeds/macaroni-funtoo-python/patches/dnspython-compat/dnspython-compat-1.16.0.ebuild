# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION=""
HOMEPAGE="https://www.dnspython.org https://pypi.org/project/dnspython/"
SRC_URI="https://files.pythonhosted.org/packages/ec/c5/14bcd63cb6d06092a004793399ec395405edf97c2301dfdc146dfbd5beed/dnspython-1.16.0.zip -> dnspython-1.16.0.zip
"

DEPEND="
	dev-python/idna[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
	dev-python/pycryptodome[${PYTHON_USEDEP}]
	dev-python/ecdsa[${PYTHON_USEDEP}]
	' -2
	)"
RDEPEND="
	${DEPEND}"
IUSE=""
SLOT="0"
LICENSE=""
KEYWORDS="*"
S="${WORKDIR}/dnspython-1.16.0"

post_src_install() {
	rm -rf ${D}/usr/bin
}