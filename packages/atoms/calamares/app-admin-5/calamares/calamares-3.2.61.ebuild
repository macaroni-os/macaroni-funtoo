# Distributed under the terms of the GNU General Public License v2
EAPI=7

KDE_TEST="true"
PYTHON_COMPAT=( python3+ )

inherit kde5 python-single-r1

DESCRIPTION="Distribution-independent installer framework"
HOMEPAGE="https://calamares.io"
SRC_URI="https://github.com/${PN}/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="5"
KEYWORDS="*"
IUSE="+networkmanager +upower"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="
	$(add_qt_dep linguist-tools)
"
COMMON_DEPEND="${PYTHON_DEPS}
	dev-cpp/yaml-cpp:=
	$(python_gen_cond_dep '
		>=dev-libs/boost-1.55:=[python,${PYTHON_USEDEP}]
		dev-libs/libpwquality[${PYTHON_USEDEP}]
	')
	$(add_qt_dep qtconcurrent)
	$(add_qt_dep qtdbus)
	$(add_qt_dep qtdeclarative)
	$(add_qt_dep qtgui)
	$(add_qt_dep qtnetwork)
	$(add_qt_dep qtsvg)
	$(add_qt_dep qtwebengine widgets)
	$(add_qt_dep qtwidgets)
	$(add_qt_dep qtxml)
	$(add_frameworks_dep kconfig)
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep kcrash)
	$(add_frameworks_dep kpackage)
	$(add_frameworks_dep kparts)
	$(add_frameworks_dep kservice)
	sys-apps/dbus
	sys-apps/dmidecode
	sys-auth/polkit-qt
	>=sys-libs/kpmcore-4.0.0:5=
"
DEPEND="${COMMON_DEPEND}
	test? ( $(add_qt_dep qttest) )
"
RDEPEND="${COMMON_DEPEND}
	app-admin/sudo
	dev-libs/libatasmart
	net-misc/rsync
	sys-boot/grub:2
	sys-boot/os-prober
	sys-fs/squashfs-tools
	sys-libs/timezone-data
	virtual/udev
	networkmanager? ( net-misc/networkmanager )
	upower? ( sys-power/upower )
"

src_prepare() {
	kde5_src_prepare
	export PYTHON_INCLUDE_DIRS="$(python_get_includedir)" \
			PYTHON_INCLUDE_PATH="$(python_get_library_path)"\
			PYTHON_CFLAGS="$(python_get_CFLAGS)"\
			PYTHON_LIBS="$(python_get_LIBS)"

	sed -i -e 's:pkexec /usr/bin/calamares:calamares-pkexec:' \
		calamares.desktop || die
	sed -i -e 's:Icon=calamares:Icon=drive-harddisk:' \
		calamares.desktop || die
}

src_configure() {
	local mycmakeargs=(
		-DINSTALL_CONFIG=ON
		-DWEBVIEW_FORCE_WEBKIT=OFF
		-DCMAKE_DISABLE_FIND_PACKAGE_LIBPARTED=ON
		-DWITH_PYTHONQT=OFF
	)

	kde5_src_configure
}

src_install() {
	kde5_src_install
	dobin "${FILESDIR}"/calamares-pkexec
}

