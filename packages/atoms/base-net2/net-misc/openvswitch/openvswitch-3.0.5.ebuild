# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )

inherit autotools python-r1 systemd tmpfiles

DESCRIPTION="Production quality, multilayer virtual switch"
HOMEPAGE="https://www.openvswitch.org"
SRC_URI="https://www.openvswitch.org/releases/openvswitch-3.0.5.tar.gz -> openvswitch-3.0.5.tar.gz"

LICENSE="Apache-2.0 GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="debug monitor +ssl systemd"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	ssl? ( dev-libs/openssl:0= )
	${PYTHON_DEPS}
	dev-python/ovs[${PYTHON_USEDEP}]
	dev-python/twisted[conch,${PYTHON_USEDEP}]
	dev-python/zope-interface[${PYTHON_USEDEP}]
	net-dns/unbound
	sys-libs/libunwind
	debug? ( dev-lang/perl )"
DEPEND="${RDEPEND}
	sys-apps/util-linux[caps]"
BDEPEND="virtual/pkgconfig"

CONFIG_CHECK="~NET_CLS_ACT ~NET_CLS_U32 ~NET_SCH_INGRESS ~NET_ACT_POLICE ~IPV6 ~TUN"
MODULE_NAMES="openvswitch(net:${S}/datapath/linux)"
BUILD_TARGETS="all"

src_prepare() {
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

	# Fix doc generation after alabaster upgrade (0.7.16) - See FL-12010
	echo "html_theme = 'sphinx_rtd_theme'" >>   Documentation/conf.py

	econf \
		--with-rundir=/var/run/openvswitch \
		--with-logdir=/var/log/openvswitch \
		--with-pkidir=/etc/ssl/openvswitch \
		--with-dbdir=/var/lib/openvswitch \
		$(use_enable ssl) \
		$(use_enable !debug ndebug)
}

src_install() {
	default

	local SCRIPT
	if use monitor; then
		for SCRIPT in ovs-{pcap,parse-backtrace,dpctl-top,l3ping,tcpdump,tcpundump,test,vlan-test} bugtool/ovs-bugtool; do
			sed -e '1s|^.*$|#!/usr/bin/python|' -i utilities/"${SCRIPT}"
			python_foreach_impl python_doscript utilities/"${SCRIPT}"
		done
		rm -r "${ED}"/usr/share/openvswitch/python || die
	fi

	keepdir /var/{lib,log}/openvswitch
	keepdir /etc/ssl/openvswitch
	fperms 0750 /etc/ssl/openvswitch

	rm -rf "${ED}"/var/run || die

	newconfd "${FILESDIR}/ovsdb-server_conf2" ovsdb-server
	newconfd "${FILESDIR}/ovs-vswitchd.confd-r2" ovs-vswitchd
	newinitd "${FILESDIR}/ovsdb-server-r1" ovsdb-server
	newinitd "${FILESDIR}/ovs-vswitchd-r1" ovs-vswitchd

	if use systemd ; then
		systemd_newunit "${FILESDIR}/ovsdb-server-r3.service" ovsdb-server.service
		systemd_newunit "${FILESDIR}/ovs-vswitchd-r3.service" ovs-vswitchd.service
		systemd_newunit rhel/usr_lib_systemd_system_ovs-delete-transient-ports.service ovs-delete-transient-ports.service
		newtmpfiles "${FILESDIR}/openvswitch.tmpfiles" openvswitch.conf
	fi

	insinto /etc/logrotate.d
	newins rhel/etc_logrotate.d_openvswitch openvswitch
}

pkg_postinst() {
	tmpfiles_process openvswitch.conf

	# only needed on non-systemd, but helps anyway
	elog "Use the following command to create an initial database for ovsdb-server:"
	elog "   emerge --config =${CATEGORY}/${PF}"
	elog "(will create a database in /var/lib/openvswitch/conf.db)"
	elog "or to convert the database to the current schema after upgrading."
}

pkg_config() {
	local db="${EROOT%}"/var/lib/openvswitch/conf.db
	if [[ -e "${db}" ]] ; then
		einfo "Database '${db}' already exists, doing schema migration..."
		einfo "(if the migration fails, make sure that ovsdb-server is not running)"
		ovsdb-tool convert "${db}" \
			"${EROOT}"/usr/share/openvswitch/vswitch.ovsschema || die "converting database failed"
	else
		einfo "Creating new database '${db}'..."
		ovsdb-tool create "${db}" \
			"${EROOT}"/usr/share/openvswitch/vswitch.ovsschema || die "creating database failed"
	fi
}