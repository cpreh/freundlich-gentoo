# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-physics/bullet/bullet-2.69.ebuild,v 1.1 2008/07/08 14:23:22 bicatali Exp $

inherit eutils toolchain-funcs

DESCRIPTION="Continuous Collision Detection and Physics Library"
HOMEPAGE="http://www.continuousphysics.com/Bullet/"
SRC_URI="http://bullet.googlecode.com/files/${P}.tgz"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="virtual/opengl virtual/glut"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.4"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch "${FILESDIR}"/cmake-install.patch
}

src_compile() {
	cmake \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_BUILD_TYPE="Release" \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		. || die "cmake failed"
	
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"

	dodoc README ChangeLog AUTHORS || die
}
