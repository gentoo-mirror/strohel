# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

WX_GTK_VER="3.0"

inherit eutils subversion wxwidgets games

MY_PV="r${PV%_*}-alpha"
MY_P=${PN}-${MY_PV}

DESCRIPTION="A free, real-time strategy game of ancient warfare"
HOMEPAGE="http://play0ad.com/"
ESVN_REPO_URI="http://svn.wildfiregames.com/public/ps/trunk"

LICENSE="GPL-2 LGPL-2.1 MIT CC-BY-SA-3.0"
SLOT="0"
KEYWORDS=""
IUSE="+sound editor fam pch test"

#	dev-lang/spidermonkey:31
RDEPEND="
	dev-libs/boost
	dev-libs/libxml2
	!games-strategy/0ad-data
	media-gfx/nvidia-texture-tools
	media-libs/libpng:0
	>=media-libs/libsdl2-2.0.2[X,opengl,video]
	net-libs/enet:1.3
	net-libs/miniupnpc
	net-libs/gloox
	net-misc/curl
	sys-libs/zlib
	virtual/jpeg:=
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXcursor
	editor? ( x11-libs/wxGTK:${WX_GTK_VER}[X,opengl] )
	sound? ( media-libs/libogg
		media-libs/libvorbis
		media-libs/openal )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( dev-lang/perl )"

S=${WORKDIR}/trunk

CHECKREQS_MEMORY="512M"
CHECKREQS_DISK_BUILD="6G"

src_unpack() {
	subversion_src_unpack
}

src_configure() {
	cd build/workspaces || die

#		--with-system-mozjs31 \
	./update-workspaces.sh \
		--with-system-nvtt \
		$(usex pch "" "--without-pch") \
		$(usex test "" "--without-tests") \
		$(usex sound "" "--without-audio") \
		$(use_enable editor atlas) \
		--bindir="${GAMES_BINDIR}" \
		--libdir="$(games_get_libdir)"/${PN} \
		--datadir="${GAMES_DATADIR}"/${PN} || die
}

src_compile() {
	# build 3rd party fcollada
#	emake -C libraries/source/fcollada/src

	# build 0ad
	emake -C build/workspaces/gcc verbose=1
}

src_test() {
	cd binaries/system || die
	./test -libdir "${S}/binaries/system" || die "test phase failed"
}

src_install() {
	newgamesbin binaries/system/pyrogenesis 0ad
	use editor && newgamesbin binaries/system/ActorEditor 0ad-ActorEditor

	insinto "${GAMES_DATADIR}"/${PN}
	doins -r binaries/data/*

	exeinto "$(games_get_libdir)"/${PN}
	doexe binaries/system/libCollada.so
	doexe libraries/source/spidermonkey/lib/*.so
	use editor && doexe binaries/system/libAtlasUI.so

	dodoc binaries/system/readme.txt
	doicon -s 128 build/resources/${PN}.png
	make_desktop_entry ${PN} "0 A.D."

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
