# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Made by LlulluTuqo
# $Header: /var/cvsroot/gentoo-x86/games-strategy/glest/glest-3.2.2.ebuild,v 1.9 2010/08/15 21:03:02 ssuominen Exp $

RESTRICT="mirror"

EAPI=3

inherit cmake-utils games

DESCRIPTION="Cross-platform 3D realtime strategy game"
HOMEPAGE="http://www.megaglest.org/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-source-${PV}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="media-libs/libsdl[joystick,video]
	media-libs/libogg
	media-libs/libvorbis
	media-libs/openal
	>dev-libs/xerces-c-3
	>=net-misc/curl-7.21.0
	virtual/opengl
	virtual/glu
	dev-lang/lua
	x11-libs/libX11
	x11-libs/wxGTK:2.8[X]
	!!<games-strategy/megaglest-3.5.1"
DEPEND="${RDEPEND}
	app-arch/p7zip"
PDEPEND="=games-strategy/megaglest-data-${PV}"

S="${WORKDIR}/${PN}-3.5.2"

src_configure() {
	local mycmakeargs=(
		-D CMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-D CUSTOM_DATA_INSTALL_PATH="${GAMES_DATADIR}/${PN}"
		-D WANT_SVN_STAMP=OFF )

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	prepgamesdirs
}
