# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# for epatch
inherit eutils

EAPI="2"
MYP="CGAL-${PVR}"

DESCRIPTION="C++ library for geometric algorithms and data structures"
HOMEPAGE="http://www.cgal.org/"
SRC_URI="http://gforge.inria.fr/frs/download.php/15692/CGAL-${MYP}.tar.gz"
RESTRICT="mirror"

LICENSE="LGPL-2.1 QPL"
SLOT="0"
KEYWORDS="~amd64"
IUSE="core imageio pdb qt3 qt4 cpack gmp gmpxx leda demos examples stdhack"

DEPEND="dev-libs/boost
	dev-libs/mpfr 
	qt3? ( x11-libs/qt:3 )
	qt4? ( x11-libs/qt-gui:4 )
	gmp? ( dev-libs/gmp )
	gmpxx? ( dev-libs/gmp[-nocxx] )"
RDEPEND="${DEPEND} "
S="${WORKDIR}/${MYP}"

src_compile() {
	local myconf=""

	use core && myconf="${myconf} -D WITH_CGAL_CORE:=1"
	use imageio && myconf="${myconf} -D WITH_CGAL_ImageIO:=1"
	use pdb && myconf="${myconf} -D WITH_CGAL_PDB:=1"
	use qt3 && myconf="${myconf} -D WITH_CGAL_Qt3:=1"
	use qt4 && myconf="${myconf} -D WITH_CGAL_Qt4:=1"
	use cpack && myconf="${myconf} -D WITH_CGAL_CPACK:=1"
	use gmp && myconf="${myconf} -D WITH_CGAL_GMP:=1"
	use gmpxx && myconf="${myconf} -D WITH_CGAL_GMPXX:=1"
	use leda && myconf="${myconf} -D WITH_CGAL_LEDA:=1"
	use demos && myconf="${myconf} -D WITH_CGAL_demos:=1"
	use examples && myconf="${myconf} -D WITH_CGAL_examples:=1"

	#use stdhack && die "ficken"
	use stdhack && epatch "${FILESDIR}/namespace-hack.patch"
	#use stdhack && epatch stdhack="-DCORE_NO_AUTOMATIC_NAMESPACE"

	mkdir build
	cd build

	cmake ${myconf} \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		-DCMAKE_INSTALL_PREFIX=/usr \
		.. || die "cmake failed"

	emake || die "emake failed"
}

src_install() {
	cd build
	emake DESTDIR=${D} install || die "emake install failed"
}
