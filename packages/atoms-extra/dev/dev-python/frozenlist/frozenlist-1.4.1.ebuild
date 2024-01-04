# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="A list-like structure which implements collections.abc.MutableSequence"
HOMEPAGE="https://github.com/aio-libs/frozenlist https://pypi.org/project/frozenlist/"
SRC_URI="https://files.pythonhosted.org/packages/cf/3d/2102257e7acad73efc4a0c306ad3953f68c504c16982bbdfee3ad75d8085/frozenlist-1.4.1.tar.gz -> frozenlist-1.4.1.tar.gz"

DEPEND="$(python_gen_cond_dep 'dev-python/pbr[${PYTHON_USEDEP}] dev-python/setuptools[${PYTHON_USEDEP}]' -3)"
IUSE=""
SLOT="0"
LICENSE="Apache-2.0"
KEYWORDS="*"
S="${WORKDIR}/frozenlist-1.4.1"