# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
MY_PV=${PV/_rc/-R}
MY_PV=${MY_PV/_p/.}
MC_PV="1.5.1"
MC_PN="minecraft-server-unobfuscated"
MC_JAR="${MC_PN}-${MC_PV}.jar"
if [[ "${PV}" = 9999* ]]; then
	_additional_inherit="git-2"
else
	_additional_inherit="vcs-shapshot"
fi

inherit games java-pkg-2 java-pkg-simple ${_additional_inherit}

DESCRIPTION="Bukkit implementation for the official Minecraft server"
HOMEPAGE="http://bukkit.org"
SRC_URI="http://repo.bukkit.org/content/repositories/releases/org/bukkit/minecraft-server/${MC_PV}/minecraft-server-${MC_PV}.jar -> ${MC_JAR}"
if [[ "${PV}" = 9999* ]]; then
	EGIT_REPO_URI="git://github.com/Bukkit/CraftBukkit.git"
	KEYWORDS=""
else
	SRC_URI="${SRC_URI}
		https://github.com/Bukkit/CraftBukkit/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ipv6"
RESTRICT="test" # Needs hamcrest-1.2?

CDEPEND="dev-java/commons-lang:2.1
	dev-java/ebean:0
	dev-java/gson:2.2.2
	dev-java/guava:10
	>=dev-java/jansi-1.8:0
	dev-java/jline:2
	dev-java/jopt-simple:0
	>=dev-java/snakeyaml-1.9:0
	~games-server/bukkit-${PV}"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.6"
#	test? ( dev-java/hamcrest
#		dev-java/junit:4 )"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.6
	games-server/minecraft-common"

S="${WORKDIR}/${P}"

JAVA_GENTOO_CLASSPATH="bukkit,commons-lang-2.1,ebean,gson-2.2.2,guava-10,jansi,jline-2,jopt-simple,snakeyaml"
JAVA_CLASSPATH_EXTRA="${DISTDIR}/${MC_JAR}"
JAVA_SRC_DIR="src/main/java"

src_unpack() {
	if [[ "${PV}" = 9999* ]]; then
		git-2_src_unpack
	else
		A="${P}.tar.gz" vcs-snapshot_src_unpack
	fi
	mkdir -p "${S}/target/classes/META-INF" || die
	cd "${S}/target/classes" || die
	unpack "${MC_JAR}"
}

java_prepare() {
	# Easier to use java-pkg-simple.
	rm -v pom.xml || die

	cp "${FILESDIR}"/directory.sh . || die
	sed -i "s/@GAMES_USER_DED@/${GAMES_USER_DED}/g" directory.sh || die

	echo "Implementation-Version: Gentoo-${PVR}" > target/classes/META-INF/MANIFEST.MF || die
	cp -r src/main/resources/* target/classes || die
}

src_install() {
	local ARGS
	use ipv6 || ARGS="-Djava.net.preferIPv4Stack=true"

	java-pkg-simple_src_install
	java-pkg_dolauncher "${PN}" -into "${GAMES_PREFIX}" -pre directory.sh \
		--java_args "-Xmx1024M -Xms512M ${ARGS}" --main org.bukkit.craftbukkit.Main

	dosym minecraft-server "/etc/init.d/${PN}"
	dodoc README.md

	prepgamesdirs
}

pkg_postinst() {
	elog "You may run ${PN} as a regular user or start a system-wide"
	elog "instance using /etc/init.d/${PN}. The multiverse files are"
	elog "stored in ~/.minecraft/servers or /var/lib/minecraft respectively."
	echo
	elog "The console for system-wide instances can be accessed by any user in"
	elog "the ${GAMES_GROUP} group using the minecraft-server-console command. This"
	elog "starts a client instance of tmux. The most important key-binding to"
	elog "remember is Ctrl-b d, which will detach the console and return you to"
	elog "your previous screen without stopping the server."
	echo
	elog "This package allows you to start multiple CraftBukkit server instances."
	elog "You can do this by adding a multiverse name after ${PN} or by"
	elog "creating a symlink such as /etc/init.d/${PN}.foo. You would"
	elog "then access the console with \"minecraft-server-console foo\". The"
	elog "default multiverse name is \"main\"."
	echo
	elog "Some Bukkit plugins store information in a database. Regardless of"
	elog "whether they handle their own database connectivity or use Bukkit's"
	elog "own Ebean solution, you can install your preferred JDBC driver through"
	elog "Portage. The available drivers are..."
	echo
	elog " # dev-java/h2"
	elog " # dev-java/sqlite-jdbc"
	elog " # dev-java/jdbc-mysql"
	elog " # dev-java/jdbc-postgresql"
	echo

	if has_version games-server/minecraft-server; then
		ewarn "You already have the official server installed. You may run both this"
		ewarn "and CraftBukkit against the same multiverse but not simultaneously."
		ewarn "This is not recommended though so don't come crying to us if it"
		ewarn "trashes your world."
		echo
	fi

	games_pkg_postinst
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
