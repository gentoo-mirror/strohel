# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="*-jython 2.7-pypy-*"

inherit distutils git-2

DESCRIPTION="Compiler for writing C extensions for the Python language"
HOMEPAGE="http://www.cython.org/ http://pypi.python.org/pypi/Cython"
EGIT_REPO_URI="git://github.com/cython/cython.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE="doc examples numpy"

DEPEND="numpy? ( >=dev-python/numpy-1.6.1-r1 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="README.txt ToDo.txt USAGE.txt"
PYTHON_MODNAME="Cython cython.py pyximport"

src_test() {
	testing() {
		"$(PYTHON)" runtests.py -vv --work-dir tests-${PYTHON_ABI}
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	python_generate_wrapper_scripts -E -f -q "${ED}usr/bin/cython"

	if use doc; then
		# "-A c" is for ignoring of "Doc/primes.c".
		dohtml -A c -r Doc/* || die "Installation of documentation failed"
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r Demos/* || die "Installation of examples failed"
	fi
}
