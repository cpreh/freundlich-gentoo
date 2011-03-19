# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.3.0_alpha20070112.ebuild,v 1.1 2007/01/18 05:13:42 vapier Exp $

ETYPE="gcc-compiler"
GCC_FILESDIR=${PORTDIR}/sys-devel/gcc/files

inherit toolchain

DESCRIPTION="The GNU Compiler Collection.  Includes C/C++, java compilers, pie+ssp extensions, Haj Ten Brugge runtime bounds checking"
HOMEPAGE="http://gcc.gnu.org/"
LICENSE="GPL-3 LGPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1"
KEYWORDS=""

IUSE="debug"

RDEPEND=">=sys-libs/zlib-1.1.4
	>=sys-devel/gcc-config-1.4
	virtual/libiconv
	>=dev-libs/gmp-4.3.2
	>=dev-libs/mpfr-2.4.2
	>=dev-libs/mpc-0.8.1
	graphite? (
		>=dev-libs/ppl-0.10
		>=dev-libs/cloog-ppl-0.15.10
	)
	!build? (
		gcj? (
			gtk? (
				x11-libs/libXt
				x11-libs/libX11
				x11-libs/libXtst
				x11-proto/xproto
				x11-proto/xextproto
				=x11-libs/gtk+-2*
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
			app-arch/zip
			app-arch/unzip
		)
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	test? (
		>=dev-util/dejagnu-1.4.4
		>=sys-devel/autogen-5.5.4
	)
	>=sys-apps/texinfo-4.8
	>=sys-devel/bison-1.875
	>=sys-devel/flex-2.5.4
	amd64? ( multilib? ( gcj? ( app-emulation/emul-linux-x86-xlibs ) ) )
	>=${CATEGORY}/binutils-2.18"
PDEPEND=">=sys-devel/gcc-config-1.4"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

src_unpack() {
	gcc_src_unpack

	use vanilla && return 0

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${GCC_FILESDIR}"/gcc-spec-env.patch
	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${GCC_FILESDIR}"/4.4.0/gcc-4.4.0-softfloat.patch

	use debug && GCC_CHECKS_LIST="yes"
}

pkg_postinst() {
	toolchain_pkg_postinst

	einfo "This gcc-4 ebuild is provided for your convenience, and the use"
	einfo "of this compiler is not supported by the Gentoo Developers."
	einfo "Please file bugs related to gcc-4 with upstream developers."
	einfo "Compiler bugs should be filed at http://gcc.gnu.org/bugzilla/"
}
