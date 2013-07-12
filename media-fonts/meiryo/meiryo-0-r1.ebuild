# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

FONT_SUFFIX="ttc"

inherit font

RESTRICT="fetch"

DESCRIPTION="Windows proprietary japanese font"
HOMEPAGE=""
SRC_URI="${P}.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

pkg_nofetch() {
	einfo "Please place ${P}.tar.bz2 in ${DISTDIR}"
}
