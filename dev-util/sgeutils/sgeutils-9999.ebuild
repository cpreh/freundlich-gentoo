# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8

inherit cmake git-r3

EGIT_REPO_URI="https://github.com/cpreh/sgeutils.git"

DESCRIPTION="Utils for developing C++/cmake based projects"
HOMEPAGE=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+sge"

RDEPEND="
	~dev-cpp/fcppt-9999
	>=dev-libs/boost-1.48.0:=
	sge? (
		~dev-games/spacegameengine-9999[parse,parsejson]
	)
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_SGE="$(usex sge)"
	)

	cmake_src_configure
}
