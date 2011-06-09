# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/musescore/musescore-0.9.4.ebuild,v 1.3 2009/07/22 17:35:31 ssuominen Exp $

EAPI=2
inherit cmake-utils eutils font

MY_P=MuseScore-${PV}

DESCRIPTION="WYSIWYG Music Score Typesetter"
HOMEPAGE="http://mscore.sourceforge.net"
SRC_URI="mirror://sourceforge/mscore/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="jack"

RDEPEND="sys-libs/zlib
	media-libs/alsa-lib
	media-sound/fluidsynth
	media-libs/portaudio
	x11-libs/qt-core:4
	x11-libs/qt-script:4
	x11-libs/qt-qt3support:4
	x11-libs/qt-gui:4
	x11-libs/qt-svg:4
	x11-libs/qtscriptgenerator
	jack? ( media-sound/jack-audio-connection-kit )"
DEPEND="${RDEPEND}
	dev-texlive/texlive-context
	app-doc/doxygen
	dev-util/pkgconfig"

S=${WORKDIR}/mscore-${PV}/mscore
VARTEXFONTS=${T}/fonts
FONT_SUFFIX=ttf
FONT_S=${S}/mscore/fonts
#MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	epatch "${FILESDIR}/${P}-no-automagic-jack.patch"
	epatch "${FILESDIR}/${P}-make-scriptgen-optional.patch"
}

src_configure() {
	mycmakeargs="$(cmake-utils_use_build jack JACK)"
	mycmakeargs="${mycmakeargs} -DBUILD_SCRIPTGEN=OFF"
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_make lupdate
	cmake-utils_src_make lrelease
	cmake-utils_src_make
}

src_install() {
	cmake-utils_src_install
	font_src_install
	dodoc ChangeLog NEWS README
	doman packaging/mscore.1
}
