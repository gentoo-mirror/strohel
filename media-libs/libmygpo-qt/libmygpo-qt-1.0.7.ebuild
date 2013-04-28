# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit cmake-utils

MY_P=${P/-qt-/-qt.}

DESCRIPTION="C++/Qt Library wrapping the gpodder.net Webservice"
HOMEPAGE="http://wiki.gpodder.org/wiki/Libmygpo-qt"
SRC_URI="http://stefan.derkits.at/files/libmygpo-qt/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-libs/qjson
	>=dev-qt/qtcore-4.6:4"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -i -s 's/${QJSON_LIBRARIES}/${QJSON_LDFLAGS}/' src/CMakeLists.txt || die "sed failed"
	cmake-utils_src_prepare
}
