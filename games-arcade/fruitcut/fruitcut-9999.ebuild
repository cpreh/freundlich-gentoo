# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit cmake-utils git-2 games

EGIT_REPO_URI="git://github.com/pmiddend/fruitcut.git"
DESCRIPTION="Arcade game where the goal is to cut fruits to earn points."
HOMEPAGE="http://fruitcut.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cegui"

DEPEND="
	>=dev-libs/boost-1.49.0
	~dev-cpp/fcppt-9999
	~dev-cpp/libawl-9999
	~dev-cpp/mizuiro-9999
	sci-physics/bullet
	cegui? (
		dev-games/cegui:1
	)
	~dev-games/spacegameengine-9999[audio,camera,cegui?,charconv,cg,config,console,fontbitmap,fontdraw,font,image,image2d,input,line_drawer,log,modelmd3,parse,renderer,shader,sprite,systems,texture,window]
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
