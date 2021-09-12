# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-r3

EGIT_REPO_URI="https://github.com/cpreh/mizuiro.git"

DESCRIPTION="A generic image library"
HOMEPAGE=""

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="
	~dev-cpp/fcppt-9999
"

DEPEND="
	${RDEPEND}
	test? (
		dev-cpp/catch
	)
"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_TEST="$(usex test)"
	)

	cmake-utils_src_configure
}
