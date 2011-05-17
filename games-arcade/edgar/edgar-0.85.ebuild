# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

RESTRICT="mirror"

inherit games

DESCRIPTION="You take on the role of Edgar, battling creatures and solving puzzles"
HOMEPAGE="http://www.parallelrealities.co.uk/projects/edgar.php"
SRC_URI="http://www.parallelrealities.co.uk/download/edgar/edgar-${PV}-1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="media-libs/libsdl
	media-libs/sdl-mixer[mikmod,vorbis]
	media-libs/sdl-image[gif,jpeg,png]
	media-libs/sdl-ttf"
DEPEND="${RDEPEND}"

src_prepare(){
	sed -i -e "s:\$(PREFIX)/games/:\$(PREFIX)/games/bin/:g" makefile || die "replacing install path failed"
	sed -i -e "s/-O2//g" makefile || die "replacing -O2 failed"
	sed -i -e "s/CFLAGS = /CFLAGS = ${CFLAGS} /g" makefile || die "replacing CFLAGS failed"
	sed -i -e "s/LFLAGS = /LFLAGS = ${LDFLAGS} /g" makefile || die "replacing LDFLAGS failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc doc/* || die "dodoc failed"
}

pkg_postinst() {
	games_pkg_postinst
}
