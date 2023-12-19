# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517="setuptools"
inherit distutils-r1

DESCRIPTION="Python binding to the Networking and Cryptography (NaCl) library"
HOMEPAGE="https://github.com/pyca/pynacl/ https://pypi.org/project/PyNaCl/"
SRC_URI="https://files.pythonhosted.org/packages/a7/22/27582568be639dfe22ddb3902225f91f2f17ceff88ce80e4db396c8986da/PyNaCl-1.5.0.tar.gz -> PyNaCl-1.5.0.tar.gz"

DEPEND="dev-python/cffi[${PYTHON_USEDEP}]"
RDEPEND="dev-python/cffi[${PYTHON_USEDEP}]"
IUSE=""
SLOT="0"
LICENSE=""
KEYWORDS="*"
S="${WORKDIR}/pynacl-1.5.0"

post_src_unpack() {
	mv ${WORKDIR}/PyNaCl-* ${S}
	default
}
