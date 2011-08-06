# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit toolchain-funcs git-2

DESCRIPTION="Digital vinyl emulation software"
HOMEPAGE="http://www.xwax.co.uk/"
EGIT_REPO_URI="file:///home/strohel/projekty/xwax/"
EGIT_BRANCH="portage"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="alsa jack oss cdda mp3 +fallback"
REQUIRED_USE="|| ( cdda mp3 fallback )
	|| ( alsa jack oss )"

RDEPEND="media-libs/libsdl
	media-libs/sdl-ttf
	media-fonts/dejavu
	alsa? ( media-libs/alsa-lib )
	jack? ( media-sound/jack-audio-connection-kit )
	cdda? ( media-sound/cdparanoia )
	mp3? ( || ( media-sound/mpg123 media-sound/mpg321 ) )
	fallback? ( virtual/ffmpeg )"
DEPEND="${RDEPEND}"

src_configure() {
	tc-export CC
	econf \
		$(use_enable alsa) \
		$(use_enable jack) \
		$(use_enable oss)
}

src_install() {
	emake DESTDIR="${D}" install
	rm -f ${D}/usr/share/doc/xwax/COPYING || die "Removing license failed"
}
