# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit cmake-utils games git-2

EGIT_REPO_URI="git://github.com/freundlich/sanguis.git"

DESCRIPTION="A crimsonland clone"
HOMEPAGE="https://github.com/freundlich/sanguis"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	~dev-cpp/fcppt-9999
	~dev-cpp/mizuiro-9999
	~dev-cpp/libawl-9999
	~dev-cpp/alda-9999
	>=dev-libs/boost-1.51.0
	=dev-games/spacegameengine-9999[cegui,charconv,config,console,font,fontdraw,image,image2d,input,log,parse,projectile,renderer,sprite,systems,texture,timer,viewport,window]
	dev-games/cegui:1
"
RDEPEND="${DEPEND}"

src_unpack() {
	git-2_src_unpack

	EGIT_SOURCEDIR="${WORKDIR}/statechart" EGIT_REPO_URI="git://github.com/freundlich/statechart.git" git-2_src_unpack
}

src_configure() {
	local mycmakeargs=(
		-D CMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-D INSTALL_LIBRARY_DIR="$(games_get_libdir)"
		-D INSTALL_DATA_DIR_BASE="${GAMES_DATADIR}"
		-D STATECHART_INCLUDE_DIR="${WORKDIR}/statechart/include"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	prepgamesdirs
}
