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
IUSE="tools"

DEPEND="
	~dev-cpp/fcppt-9999
	~dev-cpp/mizuiro-9999
	~dev-cpp/libawl-9999
	~dev-cpp/alda-9999
	>=dev-libs/boost-1.51.0
	=dev-games/spacegameengine-9999[audio,charconv,config,console,font,fontdraw,imagecolor,image2d,input,log,parse,parseini,parsejson,renderer,rucksack,sprite,systems,texture,timer,viewport,window]
	tools? ( dev-qt/qtwidgets:5 )
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-D CMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-D INSTALL_LIBRARY_DIR="$(games_get_libdir)"
		-D INSTALL_DATA_DIR_BASE="${GAMES_DATADIR}"
		$(cmake-utils_use_enable tools)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	prepgamesdirs
}
