# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-2

DESCRIPTION="Freundlich's C++ toolkit"
HOMEPAGE="http://fcppt.org"
EGIT_REPO_URI="git://github.com/freundlich/fcppt.git"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc +examples static-libs test"

RDEPEND="
	>=dev-libs/boost-1.47.0
	"
DEPEND="
	${RDEPEND}
	doc? (
		>=app-doc/doxygen-1.7.5[latex]
	)
"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_enable doc)
		$(cmake-utils_use_enable examples)
		$(cmake-utils_use_enable static-libs STATIC)
		$(cmake-utils_use_enable test)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# Remove empty directories because doxygen creates them
	find "${D}" -type d -empty -delete || die
}
