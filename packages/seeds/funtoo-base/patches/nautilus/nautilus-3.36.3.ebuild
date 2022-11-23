# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME3_LA_PUNT="yes" # Needed with USE 'sendto'

inherit gnome3 readme.gentoo-r1 virtualx multiprocessing meson

DESCRIPTION="A file manager for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Apps/Nautilus"

LICENSE="GPL-2+ LGPL-2+ FDL-1.1"
SLOT="0"
IUSE="docs exif gnome packagekit +previewer selinux +introspection +extensions"

KEYWORDS="*"

# FIXME: tests fails under Xvfb, but pass when building manually
# "FAIL: check failed in nautilus-file.c, line 8307"
# need org.gnome.SessionManager service (aka gnome-session) but cannot find it
RESTRICT="test"

# Require {glib,gdbus-codegen}-2.30.0 due to GDBus API changes between 2.29.92
# and 2.30.0
COMMON_DEPEND="
	>=dev-util/meson-0.59.1
	>=app-arch/gnome-autoar-0.2.1
	>=dev-libs/glib-2.62.2:2[dbus]
	>=x11-libs/pango-1.44.7
	>=x11-libs/gtk+-3.24.12:3[introspection?]
	>=dev-libs/libxml2-2.7.8:2
	>=media-libs/gexiv2-0.10.6
	>=gnome-base/gnome-desktop-3.34.1:3=

	gnome-base/dconf
	>=gnome-base/gsettings-desktop-schemas-3.8.0
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender

	exif? ( >=media-libs/libexif-0.6.20 )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	selinux? ( >=sys-libs/libselinux-2 )
	>=app-misc/tracker-2.1.7:=
"
DEPEND="${COMMON_DEPEND}
	>=dev-lang/perl-5
	>=dev-util/gtk-doc-am-1.10
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
	x11-base/xorg-proto
"
RDEPEND="${COMMON_DEPEND}
	!<media-video/totem-3.32.0
	packagekit? ( app-admin/packagekit-base )
"

PDEPEND="
	gnome? ( x11-themes/adwaita-icon-theme )
	previewer? ( >=gnome-extra/sushi-0.1.9 )
	>=gnome-base/gvfs-1.14
"
# Need gvfs[gtk] for recent:/// support

post_src_unpack() {
	# new glib fix:
	sed -i -e 's/volatile //' ${S}/src/nautilus-enum-types.c.template || die
}

src_prepare() {
	if use previewer; then
		DOC_CONTENTS="nautilus uses gnome-extra/sushi to preview media files.
			To activate the previewer, select a file and press space; to
			close the previewer, press space again."
	fi
	sed -i -e "s|'appdata',||g" -e "s|'desktop',||g" \
		-e "s|'desktop-autorun-software',||g" \
		data/meson.build
	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dprofiling=false
		$(meson_use introspection)
		$(meson_use docs)
		$(meson_use extensions)
		$(meson_use packagekit)
		$(meson_use selinux)
	)

	meson_src_configure
}

src_install() {
	use previewer && readme.gentoo_create_doc
	meson_src_install
}

pkg_postinst() {
	gnome3_pkg_postinst

	if use previewer; then
		readme.gentoo_print_elog
	else
		elog "To preview media files, emerge nautilus with USE=previewer"
	fi
}
