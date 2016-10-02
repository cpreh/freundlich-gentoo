# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-r3

DESCRIPTION="A serialization library"
HOMEPAGE=""
EGIT_REPO_URI="git://github.com/freundlich/alda.git"

LICENSE="LGPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs test"

RDEPEND="
	>=dev-libs/boost-1.50
	~dev-cpp/fcppt-9999
	"
DEPEND="
	${RDEPEND}
"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_STATIC="$(usex static-libs)"
		-D ENABLE_TEST="$(usex test)"
	)

	cmake-utils_src_configure
}
