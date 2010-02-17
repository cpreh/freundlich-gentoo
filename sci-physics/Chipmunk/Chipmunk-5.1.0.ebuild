# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

RESTRICT="mirror"

inherit cmake-utils

EAPI=3

DESCRIPTION="Fast and lightweight 2D rigid body physics library in C"
HOMEPAGE="http://code.google.com/p/chipmunk-physics/"
SRC_URI="http://files.slembcke.net/chipmunk/release/Chipmunk-5.x/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="demos ruby"

DEPEND="
	ruby? ( dev-lang/ruby )
"

RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=""

	use demos || use ruby || mycmakeargs+=" -DBUILD_STATIC=OFF -DINSTALL_STATIC=OFF"
	use demos || mycmakeargs+=" -DBUILD_DEMOS=OFF"
	use demos && mycmakeargs+=" -DINSTAL_DEMOS=ON"
	use ruby && mycmakeargs+=" -DBUILD_RUBY_EXT=ON"

	cmake-utils_src_configure
}
