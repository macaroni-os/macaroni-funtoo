# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ pypy )
inherit distutils-r1

DESCRIPTION="Markdown and reStructuredText in a single file."
HOMEPAGE="https://github.com/miyakogi/m2r https://pypi.org/project/m2r/"
SRC_URI="https://files.pythonhosted.org/packages/39/e7/9fae11a45f5e1a3a21d8a98d02948e597c4afd7848a0dbe1a1ebd235f13e/m2r-0.2.1.tar.gz
"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="
	python_targets_python2_7? ( dev-python/m2r-compat )
	dev-python/mistune[${PYTHON_USEDEP}]
	dev-python/docutils[${PYTHON_USEDEP}]"
IUSE="python_targets_python2_7"
SLOT="0"
LICENSE="MIT"
KEYWORDS="*"
PATCHES=(
	"$FILESDIR"/m2r-docutils.patch
)
S="${WORKDIR}/m2r-0.2.1"

python_prepare_all() {
	sed -e "s/packages=\['tests'\],/packages=[],/" -i setup.py
	distutils-r1_python_prepare_all
}
