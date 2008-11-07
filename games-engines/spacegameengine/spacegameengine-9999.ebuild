# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games git

DESCRIPTION="A portable easy to use engine written in C++"
HOMEPAGE="http://spacegameengine.sourceforge.net/"

EGIT_REPO_URI="git://git.tuxfamily.org/gitroot/sge/spacegameengine.git"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="devil dga openal opengl test truetype vorbis wave xinput"

DEPEND="${RDEPEND}
        dev-util/cmake
        dev-util/pkgconfig"
RDEPEND=">=dev-libs/boost-1.35
         x11-libs/libX11
         virtual/libc
         devil? ( media-libs/devil )
         openal? ( media-libs/openal )
         opengl? (
             media-libs/glew
             x11-libs/libXxf86vm )
         truetype? ( media-libs/freetype )
         xinput? ( dga? ( x11-libs/libXxf86dga ) )
         vorbis? ( media-libs/libvorbis )"

src_unpack() {
	git_src_unpack
	cd ${S}
}

src_compile() {
	local myconf=""

	use devil && myconf="${myconf} -D ENABLE_DEVIL:=1"
	use dga && myconf="${myconf} -D ENABLE_DGA:=1"
	use opengl && myconf="${myconf} -D ENABLE_OPENGL:=1"
	use openal && myconf="${myconf} -D ENABLE_OPENAL:=1"
	use test && myconf="${myconf} -D ENABLE_TEST:=1"
	use truetype && myconf="${myconf} -D ENABLE_FREETYPE:=1"
	use vorbis && myconf="${myconf} -D ENABLE_VORBIS:=1"
	use wave && myconf="${myconf} -D ENABLE_WAVE:=1"
	use xinput && myconf="${myconf} -D ENABLE_XINPUT:=1"

	cmake ${myconf} \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		-DCMAKE_INSTALL_PREFIX=/usr \
		. || die "cmake failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR=${D} install || die "emake install failed"
}
