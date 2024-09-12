# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools user toolchain-funcs flag-o-matic

DESCRIPTION="A Tool for network monitoring and data acquisition"
HOMEPAGE="
	http://www.tcpdump.org/
	https://github.com/the-tcpdump-group/tcpdump
"

SRC_URI="https://github.com/the-tcpdump-group/tcpdump/tarball/4a789712f187e3ac7b2c0044c3a3f8c71b83646e -> tcpdump-4.99.5-4a78971.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="+drop-root libressl smi ssl samba suid test chroot"

RDEPEND="
	drop-root? ( sys-libs/libcap-ng )
	net-libs/libpcap
	smi? ( net-libs/libsmi )
	ssl? (
		!libressl? ( >=dev-libs/openssl-0.9.6m:0= )
		libressl? ( dev-libs/libressl:= )
	)
"
DEPEND="
	${RDEPEND}
	drop-root? ( virtual/pkgconfig )
	test? (
		|| ( app-arch/sharutils sys-freebsd/freebsd-ubin )
		dev-lang/perl
	)
"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv the-tcpdump-group-tcpdump* "${S}" || die
	fi
}


pkg_setup() {
	if use drop-root || use suid; then
		enewgroup tcpdump
		enewuser tcpdump -1 -1 -1 tcpdump
	fi
}

src_prepare() {
	default

	sed -i -e '/^eapon1/d;' tests/TESTLIST || die

	# bug 630394
	sed -i -e '/^nbns-valgrind/d' tests/TESTLIST || die
	eautoreconf
}

src_configure() {
	if use drop-root; then
		append-cppflags -DHAVE_CAP_NG_H
		export LIBS=$( $(tc-getPKG_CONFIG) --libs libcap-ng )
	fi

	econf \
		$(use_enable samba smb) \
		$(use_with smi) \
		$(use_with drop-root cap-ng) \
		$(use_with chroot chroot '/var/tmp/tcpdump') \
		$(use_with ssl crypto "${EPREFIX}/usr") \
		$(usex drop-root "--with-user=tcpdump" "")
}

src_test() {
	if [[ ${EUID} -ne 0 ]] || ! use drop-root; then
		emake check
	else
		ewarn "If you want to run the test suite, make sure you either"
		ewarn "set FEATURES=userpriv or set USE=-drop-root"
	fi
}

src_install() {
	dosbin tcpdump
	doman tcpdump.1
	dodoc *.awk
	dodoc CHANGES CREDITS README.md

	if use suid; then
		fowners root:tcpdump /usr/sbin/tcpdump
		fperms 4110 /usr/sbin/tcpdump
	fi
}

pkg_preinst() {
	if use drop-root || use suid; then
		enewgroup tcpdump
		enewuser tcpdump -1 -1 -1 tcpdump
	fi
}

pkg_postinst() {
	use suid && elog "To let normal users run tcpdump add them into tcpdump group."
}
