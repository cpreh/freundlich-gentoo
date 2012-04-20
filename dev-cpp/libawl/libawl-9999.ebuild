# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils git

EGIT_REPO_URI="git://github.com/pmiddend/libawl.git"

DESCRIPTION="Abstract Window Library"
HOMEPAGE=""

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-libs/boost-1.47.0
	=dev-cpp/fcppt-9999
"
RDEPEND="${DEPEND}"
