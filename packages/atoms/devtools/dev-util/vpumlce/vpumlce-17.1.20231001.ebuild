# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit versionator eutils

MY_PN="Visual_Paradigm_CE" #"for_UML_CE"
MY_P="${MY_PN}_$(get_version_component_range 1-2)"

if [[ $(get_version_component_count) == 3 ]]; then
	MY_PV="$(replace_all_version_separators _)"
	SRC_URI_FORMAT="https://%s.dl.visual-paradigm.com/visual-paradigm/vpce$(get_version_component_range 1-2)/$(get_version_component_range 3)
		https://%s.dl.visual-paradigm.com/archives/vpce$(get_version_component_range 1-2)/$(get_version_component_range 3)"
else
	MY_PV="$(replace_all_version_separators _ $(get_version_component_range 1-2))"
	MY_PV="${MY_PV}_sp$(get_version_component_range 3)"
	MY_PV="${MY_PV}_$(get_version_component_range 4)"
	SRC_URI_FORMAT="https://%s.dl.visual-paradigm.com/visual-paradigm/${PN}$(get_version_component_range 1-2)/sp$(get_version_component_range 3)_$(get_version_component_range 4)
		https://%s.dl.visual-paradigm.com/archives/${PN}$(get_version_component_range 1-2)/sp$(get_version_component_range 3)_$(get_version_component_range 4)"
fi

URIS=`printf "${SRC_URI_FORMAT} " eu{1..9} usa{1..6} uk{1..6}`

DESCRIPTION="Visual Paradigm for UML Comunity Version"
HOMEPAGE="http://www.visual-paradigm.com"

SRC_URI="`for URI in $URIS; do printf "${URI}/%s " "${MY_PN}_${MY_PV}_Linux64_InstallFree.tar.gz"; done`"

S="${WORKDIR}/${MY_P}"

LICENSE="as-is" # actually, proprietary
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RESTRICT="mirror"

DEPEND=""
RDEPEND=">=virtual/jre-1.5
	x11-misc/xdg-utils
	sys-auth/polkit"

INSTDIR="/opt/${MY_PN}"

src_compile() {
	rm Application/bin/Visual_Paradigm_Update || die
	rm -r Application/bin/vp_windows || die
	rm -r Application/uninstaller || die

	sed -i -e '2i INSTALL4J_JAVA_HOME_OVERRIDE=$JAVA_HOME' \
		Application/bin/Visual_Paradigm_* || die
}

src_install() {
	insinto "${INSTDIR}"
	doins -r .install4j Application

	chmod +x "${D}${INSTDIR}"/Application/bin/*

	make_desktop_entry "${INSTDIR}"/Application/bin/Visual_Paradigm "Visual Paradigm for UML CE" "${INSTDIR}"/Application/resources/vpuml.png

	dodir /etc/env.d
	cat - > "${D}"/etc/env.d/99vpumlce <<EOF
CONFIG_PROTECT="${INSTDIR}/resources/product_edition.properties"
EOF
}
