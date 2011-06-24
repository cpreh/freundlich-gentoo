# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils games git

EGIT_REPO_URI="git://github.com/pmiddend/fruitcut.git"

DESCRIPTION="Arcade game where the goal is to cut fruits to earn points."
HOMEPAGE="http://fruitcut.com"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	=dev-cpp/fcppt-9999
	=dev-cpp/mizuiro-9999
	=dev-cpp/libawl-9999
	sci-physics/bullet
	>=dev-libs/boost-1.45.0
	=dev-games/spacegameengine-9999[audio,camera,cegui,config,console,fontbitmap,fonttext,image,image2d,input,line_drawer,parse,renderer,shader,sprite,systems,texture,time,window,viewport,model,md3]
	>=dev-games/cegui-0.7.5
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-D CMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-D INSTALL_LIBRARY_DIR=$(games_get_libdir)
		-D INSTALL_DATA_DIR_BASE="${GAMES_DATADIR}"
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install

	prepgamesdirs
}
