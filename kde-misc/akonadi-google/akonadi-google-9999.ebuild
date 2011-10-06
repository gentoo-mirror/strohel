# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

KDE_SCM="git"
KDE_MINIMAL="4.7"
inherit kde4-base

DESCRIPTION="Akonadi resource for Google PIM data: contacts, calendar, tasks"
HOMEPAGE="http://progdan.cz/category/akonadi-google/ https://projects.kde.org/projects/playground/pim/akonadi-google"
LICENSE="GPL-2"

SLOT="4"
IUSE=""

# yup, older kdepimlibs suffice (as per README)
DEPEND="
	dev-libs/libxslt
	dev-libs/qjson
	>=kde-base/kdepimlibs-4.6:4
"
RDEPEND="${DEPEND}
"
