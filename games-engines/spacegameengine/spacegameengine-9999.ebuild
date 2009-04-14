# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games git

DESCRIPTION="A portable, easy to use engine written in C++"
HOMEPAGE="http://spacegameengine.sourceforge.net/"

EGIT_REPO_URI="git://timeoutd.org/spacegameengine.git"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="audionull bullet cell devil dga gui ode openal opengl test truetype vorbis wave x11input"

DEPEND="${RDEPEND}
        >=dev-util/cmake-2.6
        dev-util/pkgconfig"
RDEPEND=">=dev-libs/boost-1.36
         x11-libs/libX11
         virtual/libc
         bullet? ( sci-physics/bullet )
         devil? ( media-libs/devil )
         ode? ( dev-games/ode )
         openal? ( media-libs/openal )
         opengl? (
             media-libs/glew
             virutal/opengl
             x11-libs/libXrandr
             x11-libs/libXxf86vm )
         truetype? ( media-libs/freetype )
         x11input? ( dga? ( x11-libs/libXxf86dga ) )
         vorbis? ( media-libs/libvorbis )"

src_compile() {
	local myconf=""

	use audionull && myconf="${myconf} -D ENABLE_AUDIO_NULL:=1"
	use bullet && myconf="${myconf} -D ENABLE_BULLET:=1"
	use cell || myconf="${myconf} -D ENABLE_CELL:=0"
	use devil || myconf="${myconf} -D ENABLE_DEVIL:=0"
	use dga || myconf="${myconf} -D ENABLE_DGA:=0"
	use gui || myconf="${myconf} -D ENABLE_GUI:=0"
	use ode || myconf="${myconf} -D ENABLE_ODE:=0"
	use openal || myconf="${myconf} -D ENABLE_OPENAL:=0"
	use opengl || myconf="${myconf} -D ENABLE_OPENGL:=0"
	use test || myconf="${myconf} -D ENABLE_TEST:=0"
	use truetype || myconf="${myconf} -D ENABLE_FREETYPE:=0"
	use vorbis || myconf="${myconf} -D ENABLE_VORBIS:=0"
	use wave || myconf="${myconf} -D ENABLE_WAVE:=0"
	use x11input || myconf="${myconf} -D ENABLE_X11INPUT:=0"

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
