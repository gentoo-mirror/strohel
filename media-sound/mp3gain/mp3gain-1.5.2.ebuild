# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit toolchain-funcs

MY_P=${P//./_}

DESCRIPTION="A program to analyze and adjust MP3 files to same volume"
HOMEPAGE="http://mp3gain.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}-src.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=""
DEPEND="app-arch/unzip"

S=${WORKDIR}

src_prepare() {
	sed -i \
		-e 's:CFLAGS= -Wall -O2:CFLAGS+= -Wall:' \
		-e 's:$(CC) -o:$(CC) $(LDFLAGS) -o:' \
		Makefile || die

	default_src_prepare
}

src_compile() {
	emake CC="$(tc-getCC)" || die
}

src_install() {
	dobin mp3gain || die
}
