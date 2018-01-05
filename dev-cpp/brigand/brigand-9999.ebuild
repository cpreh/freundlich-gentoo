# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="Instant compile time C++ 11 metaprogramming library"
HOMEPAGE="https://github.com/edouarda/brigand"
EGIT_REPO_URI="https://github.com/edouarda/brigand.git"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
