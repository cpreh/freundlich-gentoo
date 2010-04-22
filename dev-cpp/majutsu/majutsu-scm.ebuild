# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils git

EGIT_REPO_URI="git://timeout.supraverse.net/majutsu.git"

DESCRIPTION="A prototype of a declarative datatypes library"
HOMEPAGE=""

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-cpp/fcppt
	dev-libs/boost
"
RDEPEND="${DEPEND}"

