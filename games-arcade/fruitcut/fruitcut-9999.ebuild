# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-r3

EGIT_REPO_URI="https://github.com/pmiddend/fruitcut.git"
DESCRIPTION="Arcade game where the goal is to cut fruits to earn points."
HOMEPAGE="http://fruitcut.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+cegui"

DEPEND="
	>=dev-libs/boost-1.49.0:=
	~dev-cpp/fcppt-9999
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
		-D USE_CEGUI="$(usex cegui)"
	)

	cmake-utils_src_configure
}
