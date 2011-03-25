# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils games git

EGIT_REPO_URI="git://github.com/freundlich/sanguis.git"

DESCRIPTION="A crimsonland clone"
HOMEPAGE="http://sanguis.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	=dev-cpp/fcppt-scm
	=dev-cpp/mizuiro-scm
	=dev-cpp/libawl-scm
	>=dev-libs/boost-1.45.0
	=games-engines/spacegameengine-scm[cegui,config,fonttext,console,parse,sprite,systems,texture,time,viewport]
	>=dev-games/cegui-0.7.5
"
RDEPEND="${DEPEND}"

