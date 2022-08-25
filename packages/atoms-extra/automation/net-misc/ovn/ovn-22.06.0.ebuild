# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )

inherit autotools python-r1 systemd tmpfiles

DESCRIPTION="Open Virtual Network"
HOMEPAGE="https://www.ovn.org/"
SRC_URI="https://github.com/ovn-org/ovn/archive/refs/tags/v22.06.0.tar.gz -> ${P}.tar.gz
https://github.com/openvswitch/ovs/archive/d94cd0d3eec33e4290d7ca81918f5ac61444886e.tar.gz -> ${P}-ovs.tar.gz
"

LICENSE="Apache-2.0 GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="+dns +ssl systemd"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}
	ssl? ( dev-libs/openssl:0= )
	dns? ( net-dns/unbound )"
RDEPEND="${DEPEND}
	net-misc/openvswitch
"

src_prepare() {
	eapply_user

	rm -rf ${S}/ovs
	mv ../ovs-* ${S}/ovs

	# OVN compiles with a specific commit has of openvswitch
	# that is available under the directory ovs/
	# Before compile the ovn code is needed setup and compile
	# the ovs code.

	cd ${S}/ovs
	sed -i \
		-e '/^SUBDIRS +=.*/d' \
		datapath/Makefile.am || die "sed failed"
	eautoreconf

	cd ${S}
	eautoreconf
	default
}

src_configure() {
	# monitor is statically enabled for bug 596206
	# use monitor || export ovs_cv_python="no"
	# pyside is staticly disabled
	export ovs_cv_pyuic4="no"

	# flake8 is primarily a style guide tool, running it as part of the tests
	# in Gentoo does not make much sense, only breaks them: bug 607280
	export ovs_cv_flake8="no"

	# TODO: Check if correct enable always these flags
	export CFLAGS="${CFLAGS} -msse4.1 -mssse3"
	export CXXFLAGS="${CXXFLAGS} -msse4.1 -mssse3"

	# Configure the OpenVSwitch code
	cd ovs/
	econf --prefix=/usr \
		--with-rundir=/var/run/openvswitch \
		--with-logdir=/var/log/openvswitch \
		--with-pkidir=/etc/ssl/openvswitch \
		--with-dbdir=/var/lib/openvswitch \
		$(use_enable ssl)

	# Configure the OVN code
	cd ..
	econf --prefix=/usr \
		--localstatedir=/var \
		--sysconfdir=/etc \
		$(use_enable ssl)
}

src_compile() {
	cd ovs ; emake || die "Error on compile ovs code"
	emake
}

src_install() {
	default

	keepdir /var/{lib,log}/ovn
	keepdir /etc/ssl/ovn
	fperms 0750 /etc/ssl/ovn

	newconfd "${FILESDIR}/ovn-central.confd" ovn-central
	newconfd "${FILESDIR}/ovn-ic.confd" ovn-ic
	newconfd "${FILESDIR}/ovn-ic-ovsdb.confd" ovn-ic-ovsdb
	newconfd "${FILESDIR}/ovn-controller.confd" ovn-controller
	newconfd "${FILESDIR}/ovn-controller-vtep.confd" ovn-controller-vtep

	if use systemd ; then
		systemd_dounit "${FILESDIR}"/ovn-central.service
		systemd_dounit "${FILESDIR}"/ovn-ic.service
		systemd_dounit "${FILESDIR}"/ovn-ic-ovsdb.service
		systemd_dounit "${FILESDIR}"/ovn-controller.service
		systemd_dounit "${FILESDIR}"/ovn-controller-vtep.service
	fi

	insinto /etc/logrotate.d
	newins "${S}/rhel/etc_logrotate.d_ovn" ovn

	local nb_db="${EROOT%}"/var/lib/ovn/ovnnb_db.db
	local sb_db="${EROOT%}"/var/lib/ovn/ovnsb_db.db

	# only needed on non-systemd, but helps anyway
	elog "Use the following command to create an initial database for ovsdb-server:"
	elog "   emerge --config =${CATEGORY}/${PF}"
	elog "(will create the databases: ${nb_db}, ${sb_db})"
	elog "or to convert the database to the current schema after upgrading."
	elog "At the moment we use the ovn-ctl script so the database is also"
	elog "generated automatically with the first bootstrap."
}

pkg_config() {
	local nb_db="${EROOT%}"/var/lib/ovn/ovnnb_db.db
	local sb_db="${EROOT%}"/var/lib/ovn/ovnsb_db.db
	if [[ -e "${sb_db}" ]] ; then
		einfo "Database SouthBound'${sb_db}' already exists, doing schema migration..."
		einfo "(if the migration fails, make sure that ovsdb-server is not running)"
		ovsdb-tool convert "${sb_db}" \
			"${EROOT}"/usr/share/ovn/ovn-sb.ovsschema || die "converting database failed"
	else
		einfo "Creating new SouthBound database '${sb_db}'..."
		ovsdb-tool create "${sb_db}" \
			"${EROOT}"/usr/share/ovn/ovn-sb.ovsschema || die "creating database failed"
	fi

	if [[ -e "${nb_db}" ]] ; then
		einfo "Database NorthBound'${nb_db}' already exists, doing schema migration..."
		einfo "(if the migration fails, make sure that ovsdb-server is not running)"
		ovsdb-tool convert "${nb_db}" \
			"${EROOT}"/usr/share/ovn/ovn-nb.ovsschema || die "converting database failed"
	else
		einfo "Creating new NorthBound database '${nb_db}'..."
		ovsdb-tool create "${nb_db}" \
			"${EROOT}"/usr/share/ovn/ovn-nb.ovsschema || die "creating database failed"
	fi
}