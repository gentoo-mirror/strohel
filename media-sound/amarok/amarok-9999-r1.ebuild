# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

KDE_HANDBOOK="optional"
KDE_LINGUAS="af ar ast be bg bs ca ca@valencia cs csb da de el en_GB eo es et
eu fa fi fr ga gl he hr hu is it ja km ko ku lt lv mai ml ms nb nds ne nl nn
oc pa pl pt pt_BR ro ru se si sk sl sq sr sr@ijekavian sr@ijekavianlatin
sr@Latn sv tg th tr ug uk wa zh_CN zh_TW"
KDE_SCM="git"
KDE_REQUIRED="never"
inherit flag-o-matic kde4-base

DESCRIPTION="Advanced audio player based on KDE framework."
HOMEPAGE="http://amarok.kde.org/"
if [[ ${PV} != *9999* ]]; then
	SRC_URI="mirror://kde/stable/${PN}/${PV}/src/${P}.tar.bz2"
	KEYWORDS="~amd64 ~ppc ~x86"
else
	KEYWORDS=""
fi

LICENSE="GPL-2"
SLOT="4"
IUSE="cdda daap debug +embedded ipod lastfm mp3tunes mtp ofa opengl semantic-desktop test +utils"

# ipod requires gdk enabled and also gtk compiled in libgpod
COMMONDEPEND="
	app-crypt/qca:2
	>=app-misc/strigi-0.5.7
	$(add_kdebase_dep kdelibs 'opengl?,semantic-desktop?')
	$(add_kdebase_dep kdebase-kioslaves)
	>=media-libs/taglib-1.6.1[asf,mp4]
	>=media-libs/taglib-extras-1.0.1
	sys-libs/zlib
	>=virtual/mysql-5.1[embedded?]
	x11-libs/qt-script
	>=x11-libs/qtscriptgenerator-0.1.0
	cdda? (
		$(add_kdebase_dep libkcddb)
		$(add_kdebase_dep libkcompactdisc)
		$(add_kdebase_dep kdemultimedia-kioslaves)
	)
	ipod? ( >=media-libs/libgpod-0.7.0[gtk] )
	lastfm? ( >=media-libs/liblastfm-0.3.0 )
	mp3tunes? (
		dev-libs/glib:2
		dev-libs/libxml2
		dev-libs/openssl
		net-libs/loudmouth
		net-misc/curl
		x11-libs/qt-core[glib]
	)
	mtp? ( >=media-libs/libmtp-1.0.0 )
	ofa? ( >=media-libs/libofa-0.9.0 )
	opengl? ( virtual/opengl )
"
DEPEND="${COMMONDEPEND}
	dev-util/automoc
	dev-util/pkgconfig
	test? ( >=dev-cpp/gmock-1.4.0 )
"
RDEPEND="${COMMONDEPEND}
	$(add_kdebase_dep phonon-kde)
	!media-sound/amarok-utils
"

# tests don't currently build when MySQL embedded collection is disabled
REQUIRED_USE="test? ( embedded )"

src_prepare() {
	# only released versions have handbooks bundled
	if [[ ${PV} != *9999* ]]; then
		# en locale is special in a way that it is always enabled. English Amarok
		# handbook however lies in the doc/en_US folder and thus is not picked
		# up by kde4-functions eclass. Rename it.
		sed -e 's:add_subdirectory(en_US):add_subdirectory(en):' \
			-i "${S}/doc/CMakeLists.txt" \
			|| die "Replacing en_US by en in doc/CMakeLists.txt failed."
		mv "${S}/doc/en_US" "${S}/doc/en" || die "Moving doc/en_US to doc/en failed."
	fi

	kde4-base_src_prepare
}

src_configure() {
	# Append minimal-toc cflag for ppc64, see bug 280552 and 292707
	use ppc64 && append-flags -mminimal-toc
	local mycmakeargs

	# Mygpo-qt not yet in portage, add IUSE when available
	# we already have test in IUSE, prevent 2nd compilation in src test
	mycmakeargs=(
		-DWITH_PLAYER=ON
		-DWITH_Libgcrypt=OFF
		-DWITH_Mygpo-qt=OFF
		$(cmake-utils_use embedded WITH_MYSQL_EMBEDDED)
		$(cmake-utils_use test KDE4_BUILD_TESTS)
		$(cmake-utils_use_with ipod)
		$(cmake-utils_use_with ipod Gdk)
		$(cmake-utils_use_with lastfm LibLastFm)
		$(cmake-utils_use_with mtp)
		$(cmake-utils_use_with mp3tunes MP3Tunes)
		$(cmake-utils_use_with ofa LibOFA)
	)

	mycmakeargs+=(
		$(cmake-utils_use_with utils UTILITIES)
	)
		# $(cmake-utils_use_with semantic-desktop Nepomuk)
		# $(cmake-utils_use_with semantic-desktop Soprano)

	kde4-base_src_configure
}

src_test() {
	# prevent 2nd compilation, we have already built tests if USE=test

	local excluded_tests="testsqlscanmanager|testsqluserplaylistprovider"
	einfo "Following tests are currently excluded:"
	einfo " * testsqlscanmanager: takes too long (60s and more)"
	einfo " * testsqluserplaylistprovider: fails"
	if [[ ${PV} = 2.5* ]]; then
		excluded_tests="${excluded_tests}|testmetafiletrack|testm3uplaylist|testdynamicmodel|testonewaysynchronizationjob"
		einfo " * termatafiletrack: fails when run as root in Amarok 2.5.*"
		einfo " * testm3uplaylist: fails in Amarok 2.5.*"
		einfo " * testdynamicmodel: fails in Amarok 2.5.*"
		einfo " * testonewaysynchronizationjob: fails in Amarok 2.5.*"
	fi

	# sometimes tests timeout after 1500s; make the waiting shorter
	cmake-utils_src_test --timeout 120 --exclude-regex "${excluded_tests}"
}

pkg_postinst() {
	kde4-base_pkg_postinst

	if use daap; then
		echo
		elog "You have installed amarok with daap support."
		elog "You may be interested in installing www-servers/mongrel as well."
		echo
	fi

	if ! use embedded; then
		echo
		elog "You've disabled the amarok support for embedded mysql DBs."
		elog "You'll have to configure amarok to use an external db server."
		echo
		elog "Please read http://amarok.kde.org/wiki/MySQL_Server for details on how"
		elog "to configure the external db and migrate your data from the embedded database."
		echo

		if has_version "virtual/mysql[minimal]"; then
			elog "You built mysql with the minimal use flag, so it doesn't include the server."
			elog "You won't be able to use the local mysql installation to store your amarok collection."
			echo
		fi
	fi
}
