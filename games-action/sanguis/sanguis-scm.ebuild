# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils git

EGIT_REPO_URI="git://timeout.supraverse.net/sanguis.git"

DESCRIPTION="A crimsonland clone"
HOMEPAGE="http://redmine.supraverse.net/projects/show/sanguis"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	=dev-cpp/fcppt-scm
	>=dev-libs/boost-1.45.0
	games-engines/spacegameengine[bullet,config,console,fonttext,gui,iconv,openal,opengl,parse,png,sprite,texture,time,truetype,x11input]"
RDEPEND="${DEPEND}"
