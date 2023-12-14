# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools pam pax-utils user xdg-utils systemd

DESCRIPTION="Policy framework for controlling privileges for system-wide services"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/polkit https://gitlab.freedesktop.org/polkit/polkit"
SRC_URI="https://www.freedesktop.org/software/${PN}/releases/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="elogind examples gtk +introspection jit kde nls pam selinux +spidermonkey test"
RESTRICT="!test? ( test )"

BDEPEND="
	app-text/docbook-xml-dtd:4.1.2
	app-text/docbook-xsl-stylesheets
	dev-libs/glib
	dev-libs/gobject-introspection-common
	dev-libs/libxslt
	dev-util/glib-utils
	dev-util/gtk-doc-am
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
	introspection? ( dev-libs/gobject-introspection )
"
DEPEND="
	spidermonkey? ( dev-lang/spidermonkey:78[-debug] )
	!spidermonkey? ( dev-lang/duktape )
	dev-libs/glib:2
	dev-libs/expat
	elogind? ( sys-auth/elogind )
	pam? (
		sys-auth/pambase
		sys-libs/pam
	)
"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-policykit )
"
PDEPEND="
	gtk? ( || (
		>=gnome-extra/polkit-gnome-0.105
		>=lxde-base/lxsession-0.5.2
	) )
	kde? ( kde-plasma/polkit-kde-agent )
	!elogind? ( sys-apps/systemd )
"

DOCS=( docs/TODO HACKING NEWS README )

PATCHES=(
	"${FILESDIR}"/polkit-0.119-elogind.patch
	"${FILESDIR}"/polkit-0.118-duktape.patch
	"${FILESDIR}/polkit-0.120-CVE-2021-4115.patch"
)

QA_MULTILIB_PATHS="
	usr/lib/polkit-1/polkit-agent-helper-1
	usr/lib/polkit-1/polkitd"

pkg_setup() {
	local u=polkitd
	local g=polkitd
	local h=/var/lib/polkit-1

	enewgroup ${g}
	enewuser ${u} -1 -1 ${h} ${g}
	esethome ${u} ${h}
}

src_prepare() {
	default

	sed -i -e 's|unix-group:wheel|unix-user:0|' src/polkitbackend/*-default.rules || die #401513

	# Workaround upstream hack around standard gtk-doc behavior, bug #552170
	sed -i -e 's/@ENABLE_GTK_DOC_TRUE@\(TARGET_DIR\)/\1/' \
		-e '/install-data-local:/,/uninstall-local:/ s/@ENABLE_GTK_DOC_TRUE@//' \
		-e 's/@ENABLE_GTK_DOC_FALSE@install-data-local://' \
		docs/polkit/Makefile.in || die

	# disable broken test - bug #624022
	sed -i -e "/^SUBDIRS/s/polkitbackend//" test/Makefile.am || die

	# Fix cross-building, bug #590764, elogind patch, bug #598615
	eautoreconf
}

src_configure() {
	xdg_environment_reset

	# $(use_enable elogind libelogind)
	local myeconfargs=(
		--localstatedir="${EPREFIX}"/var
		--disable-static
		--enable-man-pages
		--disable-gtk-doc
		--disable-examples
		$(usex spidermonkey '' "--with-duktape")
		$(use_enable elogind libelogind)
		$(use_enable !elogind libsystemd-login)
		$(use_enable introspection)
		$(use_enable nls)
		$(usex pam "--with-pam-module-dir=$(getpam_mod_dir)" '')
		--with-authfw=$(usex pam pam shadow)
		$(use_enable test)
		--with-os-type=gentoo
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	default

	# Required for polkitd on hardened/PaX due to spidermonkey's JIT
	pax-mark mr src/polkitbackend/.libs/polkitd test/polkitbackend/.libs/polkitbackendjsauthoritytest
}

src_install() {
	default

	fowners -R polkitd:root /{etc,usr/share}/polkit-1/rules.d

	diropts -m0700 -o polkitd -g polkitd
	keepdir /var/lib/polkit-1

	if use examples; then
		docinto examples
		dodoc src/examples/{*.c,*.policy*}
	fi

	# allow "plugdev" group to access and manipulate removable media by default:
	insopts -m0660 -o polkitd -g root
	insinto /etc/polkit-1/rules.d
	doins $FILESDIR/50-udisks.rules

	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	chmod 0755 "${EROOT}"/usr/bin/pkexec # FL-9339 CVE-2021-4034 "temporary mitigation"
	chmod 0700 "${EROOT}"/{etc,usr/share}/polkit-1/rules.d
	chown -R polkitd:root "${EROOT}"/{etc,usr/share}/polkit-1/rules.d
	chown -R polkitd:polkitd "${EROOT}"/var/lib/polkit-1
}
