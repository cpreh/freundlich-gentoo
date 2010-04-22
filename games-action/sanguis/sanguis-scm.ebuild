# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils games git

EGIT_REPO_URI="git://timeout.supraverse.net/sanguis.git"

DESCRIPTION="A crimsonland clone"
HOMEPAGE="http://redmine.supraverse.net/projects/show/sanguis"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-cpp/fcppt
	dev-cpp/majutsu
	dev-libs/boost
	games-engines/spacegameengine[bullet,gui,openal,opengl,png,truetype,x11input]"
RDEPEND="${DEPEND}"

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
