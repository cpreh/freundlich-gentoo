# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8

inherit cmake

DESCRIPTION="Freundlich's C++ toolkit"
HOMEPAGE="https://fcppt.org"
SRC_URI="https://github.com/cpreh/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="boost catch doc examples static-libs test"

RDEPEND="
	boost? (
		>=dev-libs/boost-1.47.0:=
	)
	catch? (
		dev-cpp/catch
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

REQUIRED_USE="
	test? ( catch )
"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_BOOST="$(usex boost)"
		-D ENABLE_CATCH="$(usex catch)"
		-D ENABLE_DOC="$(usex doc)"
		-D ENABLE_EXAMPLES="$(usex examples)"
		-D ENABLE_STATIC="$(usex static-libs)"
		-D ENABLE_TEST="$(usex test)"
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Remove empty directories created by doxygen
	find "${D}" -type d -empty -delete || die
}
