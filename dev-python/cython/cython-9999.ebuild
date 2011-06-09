# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
SUPPORT_PYTHON_ABIS="1"

inherit distutils git-2

DESCRIPTION="The Cython compiler for writing C extensions for the Python language"
HOMEPAGE="http://www.cython.org/ http://pypi.python.org/pypi/Cython"
EGIT_REPO_URI="git://github.com/cython/cython.git"

LICENSE="PSF-2.4"
SLOT="0"
KEYWORDS=""
IUSE="doc examples"

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="ToDo.txt USAGE.txt"
PYTHON_MODNAME="Cython pyximport"

src_test() {
	testing() {
		rm -fr BUILD
		"$(PYTHON)" runtests.py -vv
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		# "-A c" is for ignoring of "Doc/primes.c".
		dohtml -A c -r Doc/* || die "Installation of documentation failed"
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r Demos/* || die "Installation of examples failed"
	fi
}
