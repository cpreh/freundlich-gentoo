# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-action/atanks/atanks-3.7.ebuild,v 1.2 2009/08/14 18:12:43 maekke Exp $

EAPI=2
inherit eutils games

RESTRICT="mirror"

DESCRIPTION="Worms and Scorched Earth-like game"
HOMEPAGE="http://atanks.sourceforge.net/"
SRC_URI="mirror://sourceforge/atanks/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE=""

DEPEND="media-libs/allegro[X]"

PATCHES=( "${FILESDIR}"/${P}-build.patch )

src_compile() {
	emake \
		BINDIR="${GAMES_BINDIR}" \
		INSTALLDIR="${GAMES_DATADIR}/${PN}" \
		|| die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" \
		BINDIR="${GAMES_BINDIR}" \
		INSTALLDIR="${GAMES_DATADIR}/${PN}" \
		|| die "make install failed"
	doicon ${PN}.png
	make_desktop_entry atanks "Atomic Tanks"
	dodoc Changelog README TODO
	prepgamesdirs
}
