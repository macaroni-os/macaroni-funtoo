# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake

DESCRIPTION="Libraries for messaging functions"
HOMEPAGE="https://invent.kde.org/"
SRC_URI="https://download.kde.org/Attic//release-service/25.12.2/src/messagelib-25.12.2.tar.xz -> messagelib-25.12.2.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="speech"
RDEPEND="virtual/kde-seed[gui]
	dev-qt/qtwebengine:6
	app-crypt/gpgmepp:=
	app-crypt/qgpgme:=
	dev-libs/openssl:=
	>=dev-libs/ktextaddons-1.6.0:6[speech?]
	kde-apps/akonadi:6=
	kde-apps/akonadi-contacts:6=
	kde-apps/akonadi-mime:6=
	kde-apps/akonadi-search:6=
	kde-apps/grantleetheme:6=
	kde-apps/kidentitymanagement:6=
	kde-apps/kldap:6=
	kde-apps/kmailtransport:6=
	kde-apps/kmbox:6=
	kde-apps/kmime:6=
	kde-apps/kpimtextedit:6=[speech=]
	kde-apps/libgravatar:6=
	kde-apps/libkdepim:6=
	kde-apps/libkleo:6=
	kde-apps/mimetreeparser:6=
	kde-apps/pimcommon:6=
	kde-frameworks/karchive:6
	kde-frameworks/kcalendarcore:6
	kde-frameworks/kcodecs:6
	kde-frameworks/kcompletion:6
	kde-frameworks/kconfig:6
	kde-frameworks/kcontacts:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kguiaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kiconthemes:6
	kde-frameworks/kio:6
	kde-frameworks/kitemmodels:6
	kde-frameworks/kitemviews:6
	kde-frameworks/kjobwidgets:6
	kde-frameworks/knotifications:6
	kde-frameworks/kservice:6
	kde-frameworks/ktexttemplate:6
	kde-frameworks/ktextwidgets:6
	kde-frameworks/kwidgetsaddons:6
	kde-frameworks/kwindowsystem:6
	kde-frameworks/kxmlgui:6
	kde-frameworks/sonnet:6
	kde-frameworks/syntax-highlighting:6
	
"
DEPEND="${RDEPEND}
"

src_prepare() {
	cmake_src_prepare
	sed -e 's|OPENSSL_VERSION "3.0.0"|OPENSSL_VERSION "1.0.0"|g' -i CMakeLists.txt
}

post_src_prepare() {
	local f1="messageviewer/src/dkim-verify/dkimchecksignaturejob.cpp"
	local f2="messageviewer/src/dkim-verify/tests/checkrsapublickey.cpp"

	if [ -f "$f1" ]; then
		sed -i '/core_names.h/d' "$f1"
		sed -i 's/#include <openssl\/decoder.h>/#include <openssl\/x509.h>/' "$f1"

		# 2. Replace loadRSAPublicKey
		sed -i '/static EVPPKeyPtr loadRSAPublicKey/,/^}/c\
static EVPPKeyPtr loadRSAPublicKey(const QByteArray \&der)\n{\n    EVP_PKEY *pubKey = nullptr;\n    const auto rawDer = QByteArray::fromBase64(der);\n    const unsigned char *p = reinterpret_cast<const unsigned char *>(rawDer.constData());\n    if ((pubKey = d2i_PUBKEY(nullptr, \&p, rawDer.size())) == nullptr) {\n        qCWarning(MESSAGEVIEWER_DKIMCHECKER_LOG) << "Failed to decode public key:" << ERR_error_string(ERR_get_error(), nullptr);\n        return {nullptr, EVP_PKEY_free};\n    }\n    return {pubKey, EVP_PKEY_free};\n}' "$f1"

		# 3. Replace getKeyE
		sed -i '/static uint64_t getKeyE/,/^}/c\
	static uint64_t getKeyE(EVP_PKEY *key)\n{\n    const RSA *rsa = EVP_PKEY_get0_RSA(key);\n    if (!rsa) {\n        return 0;\n    }\n    const BIGNUM *e = nullptr;\n    RSA_get0_key(rsa, nullptr, \&e, nullptr);\n    return e ? BN_get_word(e) : 0;\n}' "$f1"
    fi

	if [ -f "$f2" ]; then
		sed -i 's/#include <openssl\/decoder.h>/#include <openssl\/x509.h>/' "$f2"

		sed -i '/auto ctx = OSSL_DECODER_CTX_new_for_pkey/,/BIO_free(pubkey_bio);/c\
	const auto raw_key = QByteArray::fromBase64(ba);\n    const unsigned char *p = reinterpret_cast<const unsigned char *>(raw_key.constData());\n    if ((pkey = d2i_PUBKEY(nullptr, \&p, raw_key.size())) == nullptr) {\n        qDebug() << "Public key read failed" << ERR_error_string(ERR_get_error(), nullptr);\n    } else {\n        qDebug() << "Public key read success";\n    }\n    EVP_PKEY_free(pkey);' "$f2"
    fi

}

# vim: filetype=ebuild
