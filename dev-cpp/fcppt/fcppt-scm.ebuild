# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit cmake-utils git

EAPI="2"

DESCRIPTION="Freundlich's C++ toolkit"
HOMEPAGE=""
EGIT_REPO_URI="git://timeout.supraverse.net/fcppt.git"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="
	>=dev-libs/boost-1.41.0
	"
DEPEND="
	${RDEPEND}
	doc? (
		app-doc/doxygen
		dev-libs/boost[tools]
		dev-libs/libxslt
	)
"

src_configure() {
	local mycmakeargs=""

	use doc && mycmakeargs+="-DENABLE_DOC=ON"

	cmake-utils_src_configure
}

src_compile() {
	local ARGS="all"

	use doc && ARGS+=" doc"

	# don't quote ARGS!
	cmake-utils_src_compile $ARGS
}
