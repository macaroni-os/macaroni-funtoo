# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME3_LA_PUNT="yes"
PYTHON_COMPAT=( python3+ )

inherit gnome3 pax-utils python-r1 systemd meson ninja-utils

DESCRIPTION="Provides core UI functions for the GNOME 3 desktop"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeShell"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
IUSE="+bluetooth elogind +networkmanager nsplugin systemd"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	?? ( elogind systemd )
"

KEYWORDS="*"

COMMON_DEPEND="
	app-arch/gnome-autoar
	>=dev-util/meson-0.46.1
	>=app-accessibility/at-spi2-atk-2.5.3
	>=dev-libs/atk-2[introspection]
	>=app-crypt/gcr-3.7.5[introspection]
	>=dev-libs/glib-2.62.2:2[dbus]
	>=dev-libs/gjs-1.63.2
	>=dev-libs/gobject-introspection-1.62.0:=
	>=dev-libs/libical-3:=
	>=x11-libs/gtk+-3.24.12:3[introspection]
	>=dev-libs/libcroco-0.6.8:0.6
	>=gnome-base/gnome-desktop-3.34.1:3=[introspection]
	>=gnome-base/gsettings-desktop-schemas-3.21.3
	>=gnome-extra/evolution-data-server-3.17.2:=
	>=media-libs/gstreamer-0.11.92:1.0
	>=net-im/telepathy-logger-0.2.4[introspection]
	>=net-libs/telepathy-glib-0.19[introspection]
	>=sys-auth/polkit-0.100[introspection]
	>=x11-libs/libXfixes-5.0
	x11-libs/libXtst
	>=x11-wm/mutter-${PV}[introspection]
	>=x11-libs/startup-notification-0.11
	dev-lang/sassc
	${PYTHON_DEPS}
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-libs/dbus-glib
	dev-libs/libxml2:2
	media-libs/libcanberra[gtk3]
	media-libs/mesa
	>=media-sound/pulseaudio-2
	>=net-libs/libsoup-2.40:2.4[introspection]
	x11-libs/libX11
	x11-libs/gdk-pixbuf:2[introspection]
	x11-apps/mesa-progs
	bluetooth? ( >=net-wireless/gnome-bluetooth-3.20[introspection] )
	networkmanager? (
		app-crypt/libsecret
		>=gnome-extra/nm-applet-1.8.14
		>=net-misc/networkmanager-1.10.4:=[introspection] )
	nsplugin? ( >=dev-libs/json-glib-0.13.2 )
"
# Earlier versions of media-fonts/noto contains Arimo which is in media-fonts/croscorefonts. Thus the noto blocker.
RDEPEND="${COMMON_DEPEND}
	!<media-fonts/noto-2020
	media-fonts/cantarell
	media-fonts/croscorefonts
	media-fonts/dejavu
	media-fonts/source-pro
	media-fonts/symbola
	media-fonts/unifont
	app-accessibility/at-spi2-core:2[introspection]
	>=app-accessibility/caribou-0.4.8
	dev-libs/libgweather:2=
	>=sys-apps/accountsservice-0.6.14[introspection]
	>=sys-power/upower-0.99:=[introspection]
	x11-libs/pango[introspection]
	>=gnome-base/gnome-session-3.30.0
	>=gnome-base/gnome-settings-daemon-3.30.0
	systemd? ( >=sys-apps/systemd-186:0= )
	elogind? ( sys-auth/elogind )
	x11-misc/xdg-utils
	>=x11-themes/adwaita-icon-theme-3.30.0
	networkmanager? (
		net-misc/mobile-broadband-provider-info
		sys-libs/timezone-data )
	>=app-i18n/ibus-1.5.2[dconf(+),gtk,introspection(+)]
"
# avoid circular dependency, see bug #546134
PDEPEND="
	>=gnome-base/gdm-3.5[introspection]
	>=gnome-base/gnome-control-center-3.30.0[bluetooth(+)?,networkmanager(+)?]
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.17
	gnome-base/gnome-common
	>=sys-devel/gettext-0.19.6
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-3.36.0-improve-motd-handling.patch"
	"${FILESDIR}/${PN}-3.36.7-fix-modal-wifi-lockup.patch"
	"${FILESDIR}/${PN}-3.36.7-meson36.patch"
)

src_prepare() {
	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dsystemd=$(usex systemd true false)
		-Dnetworkmanager=$(usex networkmanager true false)
	)

	meson_src_configure
}

src_install() {
	meson_src_install
	python_replicate_script "${ED}/usr/bin/gnome-shell-extension-tool"
	python_replicate_script "${ED}/usr/bin/gnome-shell-perf-tool"

	# Required for gnome-shell on hardened/PaX, bug #398941
	# Future-proof for >=spidermonkey-1.8.7 following polkit's example
	if has_version '<dev-lang/spidermonkey-1.8.7'; then
		pax-mark mr "${ED}usr/bin/gnome-shell"{,-extension-prefs}
	elif has_version '>=dev-lang/spidermonkey-1.8.7[jit]'; then
		pax-mark m "${ED}usr/bin/gnome-shell"{,-extension-prefs}
	# Required for gnome-shell on hardened/PaX #457146 and #457194
	# PaX EMUTRAMP need to be on
	elif has_version '>=dev-libs/libffi-3.0.13[pax_kernel]'; then
		pax-mark E "${ED}usr/bin/gnome-shell"{,-extension-prefs}
	else
		pax-mark m "${ED}usr/bin/gnome-shell"{,-extension-prefs}
	fi
	insinto /usr/share/glib-2.0/schemas
	doins ${FILESDIR}/funtoo-settings.gschema.override
}

pkg_postinst() {
	gnome3_pkg_postinst
	gnome3_schemas_update

	if ! has_version 'media-libs/gst-plugins-good:1.0' || \
	   ! has_version 'media-plugins/gst-plugins-vpx:1.0'; then
		ewarn "To make use of GNOME Shell's built-in screen recording utility,"
		ewarn "you need to either install media-libs/gst-plugins-good:1.0"
		ewarn "and media-plugins/gst-plugins-vpx:1.0, or use dconf-editor to change"
		ewarn "apps.gnome-shell.recorder/pipeline to what you want to use."
	fi

	if has_version "<x11-drivers/ati-drivers-12"; then
		ewarn "GNOME Shell has been reported to show graphical corruption under"
		ewarn "x11-drivers/ati-drivers-11.*; you may want to switch to open-source"
		ewarn "drivers."
	fi

	if ! has_version "media-libs/mesa[llvm]"; then
		elog "llvmpipe is used as fallback when no 3D acceleration"
		elog "is available. You will need to enable llvm USE for"
		elog "media-libs/mesa."
	fi

	# https://bugs.gentoo.org/show_bug.cgi?id=563084
	if has_version "x11-drivers/nvidia-drivers[-kms]"; then
		ewarn "You will need to enable kms support in x11-drivers/nvidia-drivers,"
		ewarn "otherwise Gnome will fail to start"
	fi

	if use systemd && ! systemd_is_booted; then
		ewarn "${PN} needs Systemd to be *running* for working"
		ewarn "properly. Please follow this guide to migrate:"
		ewarn "https://wiki.gentoo.org/wiki/Systemd"
	fi
}
