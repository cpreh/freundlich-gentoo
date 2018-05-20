# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-r3

DESCRIPTION="Freundlich's C++ toolkit"
HOMEPAGE="http://fcppt.org"
EGIT_REPO_URI="https://github.com/freundlich/fcppt.git"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="boost doc +examples static-libs test"

RDEPEND="
	~dev-cpp/brigand-9999
	boost? (
		>=dev-libs/boost-1.47.0:=
	)
	"
DEPEND="
	${RDEPEND}
	doc? (
		>=app-doc/doxygen-1.7.5[latex]
	)
	test? (
		dev-cpp/catch
	)
"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_BOOST="$(usex boost)"
		-D ENABLE_DOC="$(usex doc)"
		-D ENABLE_EXAMPLES="$(usex examples)"
		-D ENABLE_STATIC="$(usex static-libs)"
		-D ENABLE_TEST="$(usex test)"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# Remove empty directories created by doxygen
	find "${D}" -type d -empty -delete || die
}
