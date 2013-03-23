# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.6.2.ebuild,v 1.2 2011/11/09 19:22:57 vapier Exp $

RESTRICT="mirror"

PATCH_VER="1.5"
UCLIBC_VER="1.0"

PATCH_GCC_VER="4.7.2"
PIE_GCC_VER="4.7.2"

PIE_VER="0.5.5"
SPECS_VER="0.2.0"
SPECS_GCC_VER="4.4.3"

# Hardened gcc 4 stuff
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
PIE_GLIBC_STABLE="x86 amd64 ppc ppc64 arm ia64"
PIE_UCLIBC_STABLE="x86 arm amd64 ppc ppc64"
SSP_STABLE="amd64 x86 ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
SSP_UCLIBC_STABLE=""
#end Hardened stuff

inherit toolchain

SRC_URI="
	ftp://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_PV}/gcc-${GCC_RELEASE_VER}.tar.bz2
	$(get_gcc_src_uri)"
DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3 LGPL-3 || ( GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.2"
KEYWORDS=""

RDEPEND=""
DEPEND="${RDEPEND}
	elibc_glibc? ( >=sys-libs/glibc-2.8 )
	>=${CATEGORY}/binutils-2.18"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

src_unpack() {
	EPATCH_EXCLUDE="
		11_all_default-warn-format-security.patch
		16_all_libgo-Werror-pr53679.patch
		33_all_armhf.patch
		39_all_gfortran-sysroot-pr54725.patch
		49_all_x86_pr52695_libitm-m64.patch
		67_all_gcc-poison-system-directories.patch
		74_all_gcc47_cloog-dl.patch
		82_all_alpha_4.6.4_pr56023_bootstrap.patch
		90_all_gcc-4.7-x32.patch
		93_all_pr33763_4.7.3_extern-inline.patch
		95_all_pr55940_4.7.3_x86-stack-parameters.patch
		96_all_pr56125_4.7.3_ffast-math-pow.patch
	"

	toolchain_src_unpack

	use vanilla && return 0

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch
}

pkg_setup() {
	toolchain_pkg_setup

	ewarn
	ewarn "LTO support is still experimental and unstable."
	ewarn "Any bugs resulting from the use of LTO will not be fixed."
	ewarn
}

src_install() {
	toolchain_src_install

	find "${D}/${LIBPATH}" \( -name libasan.la -o -name libtsan.la \) -exec rm '{}' \;
}
