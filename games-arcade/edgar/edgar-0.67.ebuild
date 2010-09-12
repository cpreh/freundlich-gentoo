# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

RESTRICT="mirror"

inherit games

DESCRIPTION="You take on the role of Edgar, battling creatures and solving puzzles"
HOMEPAGE="http://www.parallelrealities.co.uk/projects/edgar.php"
SRC_URI="http://www.parallelrealities.co.uk/download/edgar/edgar-${PV}-2.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="media-libs/libsdl
	media-libs/sdl-mixer
	media-libs/sdl-image
	media-libs/sdl-ttf"
DEPEND="${RDEPEND}"

src_prepare(){
	sed -i -e "s:\$(PREFIX)/games/:\$(PREFIX)/games/bin/:g" makefile || die "replacing install path failed"
	sed -i -e "s/-Os/${CFLAGS}/g" makefile || die "replacing CFLAGS failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc doc/* || die "dodoc failed"
}

pkg_postinst() {
	games_pkg_postinst
}
