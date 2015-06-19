# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
JAVA_PKG_IUSE="doc source"
if [[ "${PV}" = 9999* ]]; then
	_git_inherit="git-2"
else
	_git_inherit=""
fi

inherit games java-pkg-2 java-pkg-simple ${_git_inherit}

MY_PV=${PV/_rc/-R}
MY_PV=${MY_PV/_p/.}

DESCRIPTION="Generic API component of the plugin-based server mod for Minecraft"
HOMEPAGE="http://bukkit.org"
if [[ "${PV}" = 9999* ]]; then
	EGIT_REPO_URI="git://github.com/Bukkit/Bukkit.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/Bukkit/Bukkit/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi
LICENSE="GPL-3"
SLOT="0"
IUSE=""
RESTRICT="test" # Needs hamcrest-1.2?

CDEPEND="dev-java/commons-lang:2.1
	dev-java/ebean:0
	dev-java/guava:10
	>=dev-java/snakeyaml-1.9:0"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.6"
#	test? ( dev-java/hamcrest
#		dev-java/junit:4 )"

RDEPEND="${CDEPEND}
	>=dev-java/json-simple-1.1:0
	>=virtual/jre-1.6"

S="${WORKDIR}/${P}"

JAVA_GENTOO_CLASSPATH="commons-lang-2.1,ebean,guava-10,snakeyaml"
JAVA_SRC_DIR="src/main/java"

java_prepare() {
	# Easier to use java-pkg-simple.
	rm -v pom.xml || die

# TODO: what is this good for?
# 	mkdir -p target/classes/META-INF/maven/org.bukkit/bukkit || die
# 	echo "version=${PV}" > target/classes/META-INF/maven/org.bukkit/bukkit/pom.properties || die
}

src_install() {
	java-pkg_register-dependency json-simple
	java-pkg-simple_src_install
	dodoc README.md
}

src_test() {
	cd src/test/java || die

	local CP=".:${S}/${PN}.jar:$(java-pkg_getjars hamcrest,junit-4,${JAVA_GENTOO_CLASSPATH})"
	local TESTS=$(find * -name "*Test.java")
	TESTS="${TESTS//.java}"
	TESTS="${TESTS//\//.}"

	ejavac -cp "${CP}" -d . $(find * -name "*.java")
	ejunit4 -classpath "${CP}" ${TESTS}
}
