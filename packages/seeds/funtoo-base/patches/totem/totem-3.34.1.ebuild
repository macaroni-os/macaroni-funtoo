# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="threads(+)"

inherit gnome2 python-single-r1 meson vala

DESCRIPTION="Media player for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Videos"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
IUSE="cdr +introspection lirc nautilus +python +vala"
# see bug #359379
REQUIRED_USE="
	python? ( introspection ${PYTHON_REQUIRED_USE} )
"

KEYWORDS="*"

PATCHES=(
	"${FILESDIR}"/totem-meson36.patch
)

# FIXME:
# Runtime dependency on gnome-session-2.91
COMMON_DEPEND="
	>=dev-libs/glib-2.62.2:2[dbus]
	>=dev-libs/libpeas-1.1[gtk]
	>=dev-libs/totem-pl-parser-3.26.0:0=[introspection?]
	>=media-libs/clutter-1.17.3:1.0[gtk]
	>=media-libs/clutter-gst-2.99.2:3.0
	>=media-libs/clutter-gtk-1.8.1:1.0
	>=x11-libs/cairo-1.16.0
	>=x11-libs/gdk-pixbuf-2.39.2:2
	>=x11-libs/gtk+-3.24.12:3[introspection?]

	>=media-libs/grilo-0.3.0:0.3[playlist]
	>=media-libs/gstreamer-1.6.0:1.0
	>=media-libs/gst-plugins-base-1.6.0:1.0[X,introspection?,pango]
	media-libs/gst-plugins-good:1.0

	x11-libs/libX11

	gnome-base/gnome-desktop:3=
	gnome-base/gsettings-desktop-schemas

	cdr? (
		>=dev-libs/libxml2-2.6:2
		>=x11-libs/gtk+-3.24.12:3[X]
	)
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	lirc? ( app-misc/lirc )
	nautilus? ( >=gnome-base/nautilus-2.91.3 )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '>=dev-python/pygobject-2.90.3:3[${PYTHON_USEDEP}]') )
"
RDEPEND="${COMMON_DEPEND}
	media-plugins/grilo-plugins:0.3
	media-plugins/gst-plugins-meta:1.0
	media-plugins/gst-plugins-taglib:1.0
	x11-themes/adwaita-icon-theme
	python? (
		$(python_gen_cond_dep '
		>=dev-libs/libpeas-1.1.0[python,${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
		dev-python/dbus-python[${PYTHON_USEDEP}]
		')
		>=x11-libs/gtk+-3.24.12:3[introspection] )
"
# libxml2+gdk-pixbuf required for glib-compile-resources
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.5
	app-text/yelp-tools
	>=dev-libs/libxml2-2.6:2
	>=dev-util/meson-0.44
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	x11-base/xorg-proto
	vala? ( $(vala_depend) )
"
# docbook-xml-dtd is needed for user doc
# Prevent dev-python/pylint dep, bug #482538

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	# FL-5969. workaround sandbox violations:
	for card in /dev/dri/card* ; do
		addpredict "${card}"
	done

	for render in /dev/dri/render* ; do
		addpredict "${render}"
	done

	for vid in /dev/video* ; do
		addpredict "${vid}"
	done

	# pylint is checked unconditionally, but is only used for make check
	# appstream-util overriding necessary until upstream fixes their macro
	# to respect configure switch
	local emesonargs=(
		-Denable-easy-codec-installation=yes
		-Denable-gtk-doc=false
		-Denable-python=$(usex python yes no)
		-Dwith-plugins=auto
	)
	meson_src_configure
}

src_compile() {
	# needed parallel build fix
	eninja -C "${BUILD_DIR}" -j1
}

src_install() {
	meson_src_install
	if use python ; then
		local plugin
		for plugin in dbusservice pythonconsole opensubtitles ; do
			python_optimize "${ED}"usr/$(get_libdir)/totem/plugins/${plugin}
		done
	fi
}
