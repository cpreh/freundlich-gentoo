# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"

DESCRIPTION="Japanese dictionary by Florian Blümel"
HOMEPAGE="http://jmdict.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-db/sqlite-3
        dev-libs/expat"
DEPEND="${RDEPEND}
        sys-devel/make"
PDEPEND="app-dicts/jmdict-data"
