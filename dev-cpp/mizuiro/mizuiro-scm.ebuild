# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils git

EGIT_REPO_URI="git://timeout.supraverse.net/mizuiro.git"

DESCRIPTION="A generic image library"
HOMEPAGE=""

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+fcppt"

DEPEND="
	dev-libs/boost
	fcppt? ( >=dev-cpp/fcppt-0.3 )
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs="
		$(cmake-utils_use_enable fcppt)
	"

	cmake-utils_src_configure
}
