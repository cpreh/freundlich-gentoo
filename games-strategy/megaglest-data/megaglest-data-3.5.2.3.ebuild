# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

RESTRICT="mirror"

EAPI=3

inherit cmake-utils games

DESCRIPTION="Data for megaglest"
HOMEPAGE="http://www.megaglest.org/"
SRC_URI="mirror://sourceforge/megaglest/${P}.tar.xz"

LICENSE="glest-data"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=""
DEPEND="app-arch/p7zip"

S="${WORKDIR}"/megaglest-3.5.2

MEGAGLEST_DATAPATH="${GAMES_DATADIR}/megaglest"

src_configure() {
	cd "${S}"

	local mycmakeargs=(
		-D CMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-D MEGAGLEST_DATA_INSTALL_PATH="${MEGAGLEST_DATAPATH}" )

	cmake-utils_src_configure
}

src_install() {
	cd "${S}"

	sed -i "s:\$APPLICATIONDATAPATH\/:${MEGAGLEST_DATAPATH}:g" glest_linux.ini \
		|| die "sed of APPLICATIONDATAPATH failed"

	cmake-utils_src_install

	prepgamesdirs
}
