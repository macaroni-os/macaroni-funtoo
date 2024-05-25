# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Column approximate minimum degree ordering algorithm"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v7.7.0.tar.gz -> v7.7.0.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

RDEPEND="sci-libs/suitesparseconfig"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

post_src_unpack() {
	if [ ! -d "${WORKDIR}/${S}" ]; then
		mv "${WORKDIR}"/* "${S}" || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DSUITESPARSE_ENABLE_PROJECTS="colamd"
		-DBUILD_STATIC_LIBS=ON
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	mv ${ED}/usr/include/suitesparse/colamd.h ${ED}/usr/include/
	mv "${ED}"/usr/include/suitesparse/SuiteSparse_config.h "${ED}"/usr/include/
	rm -f "${ED}"/usr/lib64/cmake/SuiteSparse/*.cmake \
		"${ED}"/usr/lib64/cmake/SuiteSparse_config/*.cmake \
		"${ED}"/usr/lib64/libsuitesparseconfig.so* \
		"${ED}"/usr/lib64/pkgconfig/SuiteSparse_config.pc || die
}
