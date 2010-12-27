# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils git

EGIT_REPO_URI="git://github.com/Phillemann/libawl.git"

DESCRIPTION="Abstract Window Library"
HOMEPAGE=""

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opengl"

DEPEND="
	>=dev-libs/boost-1.45.0
	=dev-cpp/fcppt-scm
	opengl? ( virtual/opengl )
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs="
		$(cmake-utils_use_enable opengl)
	"

	cmake-utils_src_configure
}
