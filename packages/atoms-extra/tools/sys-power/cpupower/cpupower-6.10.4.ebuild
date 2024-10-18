# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd toolchain-funcs

DESCRIPTION="Shows and sets processor power related values"
HOMEPAGE="https://www.kernel.org/"
SRC_URI="https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-6.10.4.tar.xz -> linux-6.10.4.tar.xz"

LICENSE="GPL-2"
SLOT="0/0"
KEYWORDS="*"
IUSE="nls"

# File collision w/ headers of the deprecated cpufrequtils
RDEPEND="sys-apps/pciutils"
DEPEND="${RDEPEND}
	virtual/os-headers
	nls? ( sys-devel/gettext )"

S="${WORKDIR}/linux-${PV}"

src_configure() {
	export docdir="${EPREFIX}/usr/share/doc/${PF}"
	export mandir="${EPREFIX}/usr/share/man"
	export NLS=$(usex nls true false)
}

src_compile() {
	myemakeargs=(
		VERSION=${PV}
	)

	cd tools/power/cpupower || die
	emake "${myemakeargs[@]}"
}

src_install() {
	cd tools/power/cpupower || die
	emake "${myemakeargs[@]}" DESTDIR="${D}" install
	doheader lib/cpupower.h
	einstalldocs

	newconfd "${FILESDIR}"/conf.d-r2 cpupower
	newinitd "${FILESDIR}"/init.d-r4 cpupower

	systemd_dounit "${FILESDIR}"/cpupower-frequency-set.service
	systemd_install_serviced "${FILESDIR}"/cpupower-frequency-set.service.conf
}
