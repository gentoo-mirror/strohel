# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="Minimalist tool to control fan using temperature. Supports sysfs hwmon interface and thinkpad_acpi"
HOMEPAGE="https://phuk.ath.cx:3443/wordpress/?page_id=89 http://thinkfan.sourceforge.net/"
SRC_URI="mirror://sourceforge/thinkfan/${P}.tar.gz"

LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

# TODO: kernel checks

src_install() {
	dosbin thinkfan
	newinitd rcscripts/thinkfan.gentoo thinkfan

	docompress -x ${ROOT}usr/share/doc/${PF}/thinkfan.conf.{sysfs,thinkpad}
	dodoc ChangeLog NEWS README thinkfan.conf.{sysfs,thinkpad}

	elog "Sample configuration files have been placed to ${ROOT}usr/share/doc/${PF}/"
	elog
	if [ -f /proc/acpi/ibm/thermal ]; then
		elog "You seem to be running ThinkPad with thermal interface."
		elog "You can use thinkfan.conf.thinkpad as a base for your configuration."
	elif [ -f /proc/acpi/ibm/fan ]; then
		elog "You seem to be running ThinkPad without thermal interface."
		elog "You may want to specify sensors but not fan in your configuration file for"
		elog "additional safety (fan watchdog exposed in /proc/ibm/acpi/fan)"
	else  # no assumptions here, think of chroot, different kernel etc.
		elog "TODO"
	fi
	ewarn "Be sure to read README in any case, owherwise you may DESTROY your machine."
	elog
	elog "You may want to start thinkfan automatically during boot. Use following command:"
	elog "# rc-update add thinkfan boot"
}
