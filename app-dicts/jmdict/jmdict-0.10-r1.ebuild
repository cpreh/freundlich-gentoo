# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8
RESTRICT="mirror"

DESCRIPTION="Japanese dictionary by Florian Blümel"
HOMEPAGE="https://github.com/cpreh/jmdict"
SRC_URI="https://github.com/cpreh/${PN}/archive/${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-db/sqlite-3
	dev-libs/expat"
DEPEND="
	${RDEPEND}
	dev-build/make"
PDEPEND=">=app-dicts/jmdict-data-9999-r1"
