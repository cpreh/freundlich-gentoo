# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

RESTRICT="mirror"

EAPI=4

inherit cmake-utils

DESCRIPTION="Data for megaglest"
HOMEPAGE="http://www.megaglest.org/"
SRC_URI="mirror://sourceforge/megaglest/${P}.tar.xz"

LICENSE="glest-data"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=""
DEPEND="app-arch/p7zip"

S="${WORKDIR}"/megaglest-"${PV}"
