# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-2

EGIT_REPO_URI="git://github.com/freundlich/sgec.git"

DESCRIPTION="C bindings for spacegameengine"
HOMEPAGE="http://freundlich.github.com/sgec/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs"

DEPEND=""
RDEPEND="${DEPEND}"

RDEPEND="
	>=dev-libs/boost-1.47.0
	>=dev-cpp/fcppt-1.3.0
	~dev-cpp/libawl-9999
	~dev-games/spacegameengine-9999[font,fontdraw,image,imagecolor,input,renderer,sprite,systems,texture,viewport,window]
"

DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_enable static-libs STATIC)
		-D ENABLE_EXAMPLES=OFF
	)

	cmake-utils_src_configure
}
