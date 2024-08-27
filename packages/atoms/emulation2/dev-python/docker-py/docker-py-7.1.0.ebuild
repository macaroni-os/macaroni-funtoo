# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="Python client for Docker"
HOMEPAGE="https://github.com/docker/docker-py"
SRC_URI="https://github.com/docker/docker-py/releases/download/7.1.0/docker-7.1.0.tar.gz -> docker-7.1.0.tar.gz
"

DEPEND=""
RDEPEND="
	>=dev-python/requests-2.24.0[${PYTHON_USEDEP}]
	>=dev-python/six-1.4.0[${PYTHON_USEDEP}]
	>=dev-python/websocket-client-0.32.0[${PYTHON_USEDEP}]"

IUSE=""
SLOT="0"
LICENSE="BSD"
KEYWORDS="*"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv "${WORKDIR}"/docker-* "$S" || die
	fi
}

distutils_enable_sphinx docs 'dev-python/recommonmark' '>=dev-python/sphinx-1.4.6'
src_unpack() {
	default
	mv ${WORKDIR}/docker-* ${S} || die
}
src_prepare() {
	default
	sed -i -e 's|^license =.*|license = {text = "Apache-2.0"}|g' pyproject.toml
	distutils-r1_src_prepare
}
