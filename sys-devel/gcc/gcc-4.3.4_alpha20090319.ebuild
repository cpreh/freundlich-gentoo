# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.3.0_alpha20070112.ebuild,v 1.1 2007/01/18 05:13:42 vapier Exp $

ETYPE="gcc-compiler"
GCC_FILESDIR=${PORTDIR}/sys-devel/gcc/files

inherit toolchain

DESCRIPTION="The GNU Compiler Collection.  Includes C/C++, java compilers, pie+ssp extensions, Haj Ten Brugge runtime bounds checking"

LICENSE="GPL-2 LGPL-2.1"
KEYWORDS=""

RDEPEND=">=sys-libs/zlib-1.1.4
	|| ( >=sys-devel/gcc-config-1.3.12-r4 app-admin/eselect-compiler )
	virtual/libiconv
	>=dev-libs/gmp-4.2.1
	>=dev-libs/mpfr-2.3
	!build? (
		gcj? (
			gtk? (
				|| ( ( x11-libs/libXt x11-libs/libX11 x11-libs/libXtst x11-proto/xproto x11-proto/xextproto ) virtual/x11 )
				>=x11-libs/gtk+-2.2
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
		)
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875
	>=${CATEGORY}/binutils-2.16.1"
PDEPEND="|| ( sys-devel/gcc-config app-admin/eselect-compiler )"
if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.3.6 )"
fi

src_unpack() {
	gcc_src_unpack

	use vanilla && return 0

	# Fix cross-compiling
	epatch "${GCC_FILESDIR}"/4.1.0/gcc-4.1.0-cross-compile.patch
}

pkg_postinst() {
	toolchain_pkg_postinst

	einfo "This gcc-4 ebuild is provided for your convenience, and the use"
	einfo "of this compiler is not supported by the Gentoo Developers."
	einfo "Please file bugs related to gcc-4 with upstream developers."
	einfo "Compiler bugs should be filed at http://gcc.gnu.org/bugzilla/"
}
