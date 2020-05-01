# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-r3

EGIT_REPO_URI="https://github.com/freundlich/sanguis.git"

DESCRIPTION="A crimsonland clone"
HOMEPAGE="https://github.com/freundlich/sanguis"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+client tools"

DEPEND="
	>=dev-cpp/fcppt-9999[boost]
	dev-cpp/metal
	~dev-cpp/alda-9999[net]
	>=dev-libs/boost-1.51.0:=
	~dev-games/spacegameengine-9999[charconv,config,console,font,parse,parsejson,timer]
	client? (
		~dev-cpp/libawl-9999
		dev-games/spacegameengine[audio,consolegfx,cursor,fontdraw,gui,imagecolor,image2d,input,log,parseini,renderer,rucksack,rucksackviewport,sprite,systems,texture,viewport,window]
	)
	tools? (
		dev-qt/qtwidgets:5
		dev-games/spacegameengine[image2d]
	)
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_CLIENT="$(usex client)"
		-D ENABLE_TOOLS="$(usex tools)"
	)

	cmake-utils_src_configure
}
