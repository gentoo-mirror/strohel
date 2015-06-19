# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
CMAKE_IN_SOURCE_BUILD=1
inherit cmake-utils git-2

DESCRIPTION="A library for reading and editing audio meta data"
HOMEPAGE="http://developer.kde.org/~wheeler/taglib.html"
EGIT_REPO_URI="git://github.com/taglib/taglib.git"

LICENSE="LGPL-2.1 MPL-1.1"
KEYWORDS=""
SLOT="0"
IUSE="+asf debug examples +mp4 test"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( dev-util/cppunit )
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.6.1-install-examples.patch
)

DOCS=( AUTHORS NEWS )

src_configure() {
	mycmakeargs=(
		$(cmake-utils_use_build examples)
		$(cmake-utils_use_build test TESTS)
		$(cmake-utils_use_with asf)
		$(cmake-utils_use_with mp4)
	)

	cmake-utils_src_configure
}

src_test() {
	# ctest does not work
	default
}

pkg_postinst() {
	if ! use asf; then
		elog "You've chosen to disable the asf use flag, thus taglib won't include"
		elog "support for Microsoft's 'advanced systems format' media container"
	fi
	if ! use mp4; then
		elog "You've chosen to disable the mp4 use flag, thus taglib won't include"
		elog "support for the MPEG-4 part 14 / MP4 media container"
	fi
}
