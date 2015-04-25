# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

CMAKE_MIN_VERSION="2.8.12"
inherit cmake-utils git-2

DESCRIPTION="A serialization library"
HOMEPAGE=""
EGIT_REPO_URI="git://github.com/freundlich/alda.git"

LICENSE="LGPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs test"

RDEPEND="
	>=dev-libs/boost-1.50
	>=dev-cpp/fcppt-1.3.0
	~dev-cpp/majutsu-9999
	"
DEPEND="
	${RDEPEND}
"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_enable static-libs STATIC)
		$(cmake-utils_use_enable test)
	)

	cmake-utils_src_configure
}
