# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6
RESTRICT="mirror"

DESCRIPTION="Japanese dictionary by Florian Blümel"
HOMEPAGE="https://github.com/freundlich/jmdict"
SRC_URI="https://github.com/freundlich/${PN}/archive/${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-db/sqlite-3
        dev-libs/expat"
DEPEND="${RDEPEND}
        sys-devel/make"
PDEPEND=">=app-dicts/jmdict-data-9999-r1"
