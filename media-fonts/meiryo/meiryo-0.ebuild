# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

RESTRICT="fetch"

EAPI="2"

DESCRIPTION="Windows proprietary japanese font"
HOMEPAGE=""
SRC_URI="http://test/${P}.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	local installdest="${D}/usr/share/fonts/truetype"
	mkdir -p "${installdest}"
	cp meiryob.ttc meiryo.ttc ${installdest}
}
