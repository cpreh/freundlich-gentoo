# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-r3

EGIT_REPO_URI="git://github.com/freundlich/libawl.git"

DESCRIPTION="Abstract Window Library"
HOMEPAGE=""

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+examples static-libs"

RDEPEND="
	>=dev-libs/boost-1.47.0
	>=dev-cpp/fcppt-1.3.0
	x11-libs/libX11
"

DEPEND="
	${RDEPEND}
	x11-proto/xproto
"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_X11=ON
		-D ENABLE_WAYLAND=OFF
		-D ENABLE_EXAMPLES="$(usex examples)"
		-D ENABLE_STATIC="$(usex static-libs)"
	)

	cmake-utils_src_configure
}
