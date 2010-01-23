# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit cmake-utils git

EAPI="2"

DESCRIPTION="Freundlich's C++ toolkit"
HOMEPAGE=""
EGIT_REPO_URI="git://timeout.supraverse.net/fcppt.git"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/boost"
RDEPEND="${DEPEND}"

