# Distributed under the terms of the GNU General Public License v2

EAPI=6
CMAKE_BUILD_TYPE=Release
PYTHON_COMPAT=( python3+ )

inherit eutils user systemd python-any-r1 cmake-utils

DESCRIPTION="The multi-purpose multi-model NoSQL DB"
HOMEPAGE="http://www.arangodb.org/"
SRC_URI="https://github.com/arangodb/arangodb/archive/v3.9.5.tar.gz -> arangodb-v3.9.5.tar.gz"

LICENSE="Apache-2.0"
SLOT="3"
KEYWORDS="~amd64 ~arm"
IUSE="system-boost jemalloc systemd"

DEPEND=">=sys-libs/readline-6.2_p1
	>=dev-libs/openssl-1.1.0[-bindist]
	system-boost? ( dev-libs/boost )
	jemalloc? ( dev-libs/jemalloc )
	${PYTHON_DEPEND}"
RDEPEND="${DEPEND}"

pkg_setup() {
	python-any-r1_pkg_setup
	ebegin "Ensuring arangodb3 user and group exist"
	enewgroup arangodb3
	enewuser arangodb3 -1 -1 -1 arangodb3
	eend $?
}

src_prepare() {
	cmake-utils_src_prepare

	sed -i -e 's?@PKGDATADIR@?/usr/share/arangodb3?' \
		-e 's|= arangodb$|= arangodb3|g' \
		etc/arangodb3/arangod.conf.in || die 'sed arangod.conf failed'
	sed -i 's?@PKGDATADIR@?/usr/share/arangodb3?' etc/arangodb3/arangosh.conf.in || die 'sed arangosh.conf failed'

	sed -i -e 's: arangodb : arangodb3 :g' Installation/logrotate.d/arangod.systemd || die 'sed logrotate file failed'
}

src_configure() {

	export CFLAGS="${CFLAGS} -msse4.1 -mssse3"
	export CXXFLAGS="${CXXFLAGS} -msse4.1 -mssse3"

	local mycmakeargs=(
		#-DVERBOSE=On
		-DUSE_OPTIMIZE_FOR_ARCHITECTURE=Off
		-DARANGODB_USE_GOOGLE_TESTS=0
		-DCMAKE_BUILD_TYPE=RelWithDebInfo
		-DCMAKE_C_FLAGS="${CFLAGS}"
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
		#-DETCDIR=/etc
		#-DVARDIR=/var
		-DUSE_SSE4_2=false
		-DCMAKE_INSTALL_DOCDIR=/usr/share/arangodb3
		-DCMAKE_INSTALL_SYSCONFDIR=/etc
		-DCMAKE_INSTALL_PREFIX:PATH=/usr
		-DCMAKE_INSTALL_LOCALSTATEDIR=/var
		-DCMAKE_SKIP_RPATH:BOOL=ON
		-DLOGROTATE_GROUP=arangodb3
		-DOPENSSL_ROOT_DIR=/usr/include/openssl
	)
	if use system-boost ; then
		mycmakeargs+=( -DUSE_BOOST_SYSTEM_LIBS=ON )
	else
		mycmakeargs+=( -DUSE_BOOST_SYSTEM_LIBS=OFF )
	fi

	if use jemalloc ; then
		mycmakeargs+=( -DUSE_JEMALLOC=ON )
	else
		mycmakeargs+=( -DUSE_JEMALLOC=OFF )
	fi

	cmake-utils_src_configure
}

src_install() {
	diropts -m0750 -o arangodb3 -g arangodb3
	dodir /var/log/arangodb3
	keepdir /var/log/arangodb3
	dodir /var/lib/arangodb3
	keepdir /var/lib/arangodb3
	dodir /var/lib/arangodb3-apps
	keepdir /var/lib/arangodb3-apps
	diropts
	fowners -R arangodb3:arangodb3 /var/log/arangodb3
	fowners -R arangodb3:arangodb3 /var/lib/arangodb3
	fowners -R arangodb3:arangodb3 /var/lib/arangodb3-apps

	cmake-utils_src_install

	# I use our systemd service (seems not available on 3.9.5)
	#rm "${D}/usr/lib/systemd/system/arangodb3.service"

	newinitd "${FILESDIR}"/arangodb3.initd arangodb3

	if use systemd ; then
		systemd_dounit "${FILESDIR}"/arangodb3.service
	fi
}

