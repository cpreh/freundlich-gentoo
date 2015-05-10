# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils games git-2

EGIT_REPO_URI="git://github.com/pmiddend/fruitcut.git"
DESCRIPTION="Arcade game where the goal is to cut fruits to earn points."
HOMEPAGE="http://fruitcut.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cegui"

DEPEND="
	>=dev-libs/boost-1.49.0
	>=dev-cpp/fcppt-1.3.0
	~dev-cpp/libawl-9999
	~dev-cpp/mizuiro-9999
	sci-physics/bullet
	cegui? (
		>=dev-games/cegui-0.8.0
	)
	~dev-games/spacegameengine-9999[audio,camera,cegui?,charconv,cg,config,fontbitmap,fontdraw,font,image,image2d,input,line_drawer,log,modelmd3,parse,parsejson,renderer,shader,sprite,systems,texture,window]
"

RDEPEND="${DEPEND}"


src_configure() {
	local mycmakeargs=(
		"-DCMAKE_INSTALL_PREFIX=${GAMES_PREFIX}"
		"-DINSTALL_LIBRARY_DIR=$(games_get_libdir)"
		"-DINSTALL_DATA_DIR_BASE=${GAMES_DATADIR}"
		"$(cmake-utils_use cegui CEGUI)"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	prepgamesdirs
}
