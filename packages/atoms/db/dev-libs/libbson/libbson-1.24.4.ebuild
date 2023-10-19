# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Library routines related to building,parsing and iterating BSON documents"
HOMEPAGE="https://github.com/mongodb/mongo-c-driver/tree/master/src/libbson"
SRC_URI="https://github.com/mongodb/mongo-c-driver/releases/download/1.24.4/mongo-c-driver-1.24.4.tar.gz -> libbson-1.24.4.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="examples static-libs"

DEPEND="dev-python/sphinx"

S="${WORKDIR}/mongo-c-driver-${PV}"

src_prepare() {
	cmake_src_prepare

	# remove doc files
	sed -i '/^\s*install\s*(FILES COPYING NEWS/,/^\s*)/ {d}' CMakeLists.txt || die

	sed -i -e 's|${PROJECT_SOURCE_DIR}/src/bson/bcon.h|${PROJECT_SOURCE_DIR}/src/bson/bcon.h\n   $\{PROJECT_SOURCE_DIR\}/../common/bson-dsl.h|g' \
	src/libbson/CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DUSE_SYSTEM_LIBBSON=FALSE
		-DENABLE_EXAMPLES=OFF
		-DENABLE_MAN_PAGES=ON
		-DENABLE_MONGOC=OFF
		-DENABLE_TESTS=OFF
		-DENABLE_STATIC="$(usex static-libs ON OFF)"
		-DENABLE_UNINSTALL=OFF
	)

	cmake_src_configure
}

src_install() {
	if use examples; then
		docinto examples
		dodoc src/libbson/examples/*.c
	fi

	cmake_src_install
}
