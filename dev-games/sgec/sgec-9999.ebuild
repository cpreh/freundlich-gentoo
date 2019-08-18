# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-r3

EGIT_REPO_URI="https://github.com/freundlich/sgec.git"

DESCRIPTION="C bindings for spacegameengine"
HOMEPAGE="http://freundlich.github.com/sgec/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs"

DEPEND=""
RDEPEND="${DEPEND}"

RDEPEND="
	~dev-cpp/fcppt-9999
	~dev-cpp/libawl-9999
	~dev-games/spacegameengine-9999[font,fontdraw,image,imagecolor,input,renderer,sprite,systems,texture,viewport,window]
"

DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_STATIC="$(usex static-libs)"
		-D ENABLE_EXAMPLES=OFF
	)

	cmake-utils_src_configure
}
