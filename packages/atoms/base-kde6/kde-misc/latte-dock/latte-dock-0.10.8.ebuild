# Distributed under the terms of the GNU General Public License v2

EAPI=7

FRAMEWORKS_MINIMAL=5.98.0
QT_MINIMAL=5.15.2
inherit kde5

DESCRIPTION="Elegant dock, based on KDE Frameworks"
HOMEPAGE="https://apps.kde.org/en/latte-dock"
SRC_URI="mirror://kde/stable/${PN}/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE=""

# drop qtdeclarative subslot operator when QT_MINIMAL >= 5.14.0
DEPEND="
	$(add_qt_dep qtdbus)
	$(add_qt_dep qtdeclarative)
	$(add_qt_dep qtgraphicaleffects)
	|| (
		$(add_qt_dep qtgui 'X(-)')
		$(add_qt_dep qtgui 'xcb(-)')
	)
	$(add_qt_dep qtwidgets)
	$(add_qt_dep qtx11extras)
	$(add_frameworks_dep kactivities)
	$(add_frameworks_dep karchive)
	$(add_frameworks_dep kconfig)
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep kcrash)
	$(add_frameworks_dep kdbusaddons)
	$(add_frameworks_dep kdeclarative)
	$(add_frameworks_dep kglobalaccel)
	$(add_frameworks_dep kguiaddons)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep kiconthemes)
	$(add_frameworks_dep knewstuff)
	$(add_frameworks_dep knotifications)
	$(add_frameworks_dep kpackage)
	$(add_frameworks_dep kwayland)
	$(add_frameworks_dep kwindowsystem)
	$(add_frameworks_dep kxmlgui)
	$(add_frameworks_dep plasma X)
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
"
RDEPEND="${DEPEND}
	$(add_qt_dep qtquickcontrols)
	$(add_qt_dep qtquickcontrols2)
"

DOCS=( CHANGELOG.md README.md )
