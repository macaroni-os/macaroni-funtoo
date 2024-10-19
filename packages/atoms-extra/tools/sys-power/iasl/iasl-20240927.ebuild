# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit edos2unix toolchain-funcs

MY_PN=acpica-unix
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Intel ACPI Source Language (ASL) compiler"
HOMEPAGE="https://www.acpica.org/downloads/"
SRC_URI="https://github.com/user-attachments/files/17171019/${MY_P}.tar.gz"
LICENSE="iASL"
SLOT="0"
KEYWORDS="*"

BDEPEND="
	sys-devel/bison
	sys-devel/flex"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	find "${S}" -type f -name 'Makefile*' -print0 | \
		xargs -0 -I '{}' \
		sed -r -e 's:-\<Werror\>::g' -e "s:/usr:${EPREFIX}/usr:g" \
		-i '{}' \
		|| die
}

src_configure() {
	tc-export CC

	# BITS is tied to ARCH - please set appropriately if you add new keywords
	if [[ $ARCH == @(amd64|amd64-fbsd) ]] ; then
		export BITS=64
	else
		export BITS=32
	fi
}

src_compile() {
	emake -C generate/unix BITS="${BITS}"
}

src_install() {
	cd generate/unix || die
	emake install DESTDIR="${D}" BITS=${BITS}
	default

	dodoc "${S}"/changes.txt
	newdoc "${S}"/source/compiler/readme.txt compiler-readme.txt
	newdoc "${S}"/generate/unix/readme.txt unix-readme.txt
	newdoc "${S}"/generate/lint/readme.txt lint-readme.txt
	newdoc "${S}"/source/compiler/new_table.txt compiler-new_table.txt
}
