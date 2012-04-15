# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit cmake-utils

DESCRIPTION="Freundlich's C++ toolkit"
HOMEPAGE="http://redmine.supraverse.net/projects/fcppt"
SRC_URI="http://fcppt.org/downloads/${P}.tar.bz2"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc static-libs"

RDEPEND="
	>=dev-libs/boost-1.47.0
	"
DEPEND="
	${RDEPEND}
	doc? (
		app-doc/doxygen
		app-text/dvipsk
		app-text/ghostscript-gpl
		dev-texlive/texlive-latex
	)
"

src_configure() {
	local mycmakeargs=""

	use doc && mycmakeargs+="-D ENABLE_DOC=ON"

	use static-libs && mycmakeargs+=" -D ENABLE_STATIC=ON"

	cmake-utils_src_configure
}

src_compile() {
	local ARGS="all"

	use doc && ARGS+=" doc"

	# don't quote ARGS!
	cmake-utils_src_compile $ARGS
}

src_install() {
	cmake-utils_src_install

	# remove empty directories because doxygen creates them
	find "${D}" -type d -empty -delete || die
}
