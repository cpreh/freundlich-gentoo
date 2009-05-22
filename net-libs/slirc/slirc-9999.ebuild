# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion

DESCRIPTION="libslIRC is an easy to use, message loop based IRC library written in and written for C++."
HOMEPAGE="http://libslirc.sourceforge.net/"
ESVN_REPO_URI="https://libslirc.svn.sourceforge.net/svnroot/libslirc"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
#EAPI="paludis-1"

DEPEND="${RDEPEND}
        dev-util/pkgconfig
        dev-util/cmake"
#RDEPEND="dev-libs/boost[threads]"
# boost doesn't have +threads anymore?
RDEPEND="dev-libs/boost
         virtual/libiconv"

src_unpack() {
	subversion_src_unpack
	epatch "${FILESDIR}/slirc.patch"
}

src_compile() {
	cd ${S}/libslirc2/trunk

	local myconf=""

	#if use debug; then
	#	myconf="${myconf} -D ENABLE_DEBUG:=1"
	#fi

	cmake ${myconf} \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		-DCMAKE_INSTALL_PREFIX=/usr \
		. || die "cmake failed"

	emake || die "emake failed"
}

src_install() {
	cd ${S}/libslirc2/trunk
	emake DESTDIR=${D} install || die "emake install failed"
}
