# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

CMAKE_MIN_VERSION="2.8.12"
inherit cmake-utils git-2

EGIT_REPO_URI="git://github.com/freundlich/sgeutils.git"

DESCRIPTION="Utils for developing C++/cmake based projects"
HOMEPAGE="https://github.com/freundlich/sgeutils"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+sge"

RDEPEND="
	>=dev-cpp/fcppt-1.3.0
	dev-libs/boost
	sge? (
		~dev-games/spacegameengine-9999[parse,parsejson]
	)
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_enable sge)
	)

	cmake-utils_src_configure
}
