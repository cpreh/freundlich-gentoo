# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils

DESCRIPTION="Metal is a single-header C++11 library designed to make you love template metaprogramming."
HOMEPAGE="https://github.com/brunocodutra/metal"
SRC_URI="https://github.com/brunocodutra/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-D METAL_BUILD_DOC="$(usex doc)"
		-D METAL_BUILD_EXAMPLES=OFF
		-D METAL_BUILD_TESTS=OFF
	)

	cmake-utils_src_configure
}
