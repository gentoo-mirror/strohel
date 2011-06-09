# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="2D car racing. 7 different tracks, many cars, night racing and many more."
HOMEPAGE="http://hippo.nipax.cz/download.en.php"
SRC_URI="http://hippo.nipax.cz/src/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="media-libs/allegro:0
	media-libs/jpeg"
RDEPEND="${DEPEND}"

src_install() {
	# DESTDIR in Makefile is misinterpreted
	emake DESTDIR="${D}/usr" install  || die "emake install failed"
}
