# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Memory efficient serialization library"
HOMEPAGE="
	https://flatbuffers.dev/
	https://github.com/google/flatbuffers/
"
SRC_URI="
	https://github.com/google/flatbuffers/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE="static-libs"

src_configure() {
	local mycmakeargs=(
		-DFLATBUFFERS_BUILD_FLATLIB=$(usex static-libs)
		-DFLATBUFFERS_BUILD_SHAREDLIB=ON
		-DFLATBUFFERS_BUILD_TESTS=OFF
		-DFLATBUFFERS_BUILD_BENCHMARKS=OFF
	)

	cmake_src_configure
}
