# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-r3

EGIT_REPO_URI="https://github.com/freundlich/libawl.git"

DESCRIPTION="Abstract Window Library"
HOMEPAGE=""

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+X +examples sdl static-libs wayland"

RDEPEND="
	~dev-cpp/fcppt-9999
	X? (
		x11-libs/libX11
	)
	sdl? (
		media-libs/libsdl2
	)
	wayland? (
		dev-libs/wayland
	)
"

DEPEND="
	${RDEPEND}
"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_EXAMPLES="$(usex examples)"
		-D ENABLE_SDL="$(usex sdl)"
		-D ENABLE_STATIC="$(usex static-libs)"
		-D ENABLE_X11="$(usex X)"
		-D ENABLE_WAYLAND="$(usex wayland)"
	)

	cmake-utils_src_configure
}
