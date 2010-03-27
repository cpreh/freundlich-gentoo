# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit cmake-utils git

EAPI="2"

DESCRIPTION="Phillemann's C++ gitbot"
HOMEPAGE=""
EGIT_REPO_URI="git://timeout.supraverse.net/gitbot.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-cpp/fcppt-0.1
	dev-libs/boost"
RDEPEND="${DEPEND}"

