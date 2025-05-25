# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Qt GUI for System Statistics"
HOMEPAGE="https://lxqt.github.io/"

SRC_URI="https://github.com/lxqt/libsysstat/releases/download/0.4.6/libsysstat-0.4.6.tar.xz"
KEYWORDS="*"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"

BDEPEND="dev-util/lxqt-build-tools"
DEPEND="dev-qt/qtcore:5"
RDEPEND="${DEPEND}"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv "${WORKDIR}"/* "${S}" || die
	fi
}
