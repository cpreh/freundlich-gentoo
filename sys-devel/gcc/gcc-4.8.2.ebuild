# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.8.1-r1.ebuild,v 1.1 2013/10/07 05:40:52 dirtyepic Exp $

PATCH_VER="1.2"
UCLIBC_VER="1.0"

# Hardened gcc 4 stuff
PATCH_GCC_VER="4.8.1"
PIE_GCC_VER="4.8.1"
PIE_VER="0.5.7"
SPECS_VER="0.2.0"
SPECS_GCC_VER="4.4.3"
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
PIE_GLIBC_STABLE="x86 amd64 mips ppc ppc64 arm ia64"
PIE_UCLIBC_STABLE="x86 arm amd64 mips ppc ppc64"
SSP_STABLE="amd64 x86 mips ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
# uclibc need to be >= 0.9.33
SSP_UCLIBC_STABLE="x86 amd64 mips ppc ppc64 arm"
#end Hardened stuff

inherit toolchain

SRC_URI="
	ftp://ftp.gnu.org/gnu/gcc/${P}/${P}.tar.bz2
	$(get_gcc_src_uri)"

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"

RDEPEND=""
DEPEND="${RDEPEND}
	elibc_glibc? ( >=sys-libs/glibc-2.8 )
	>=${CATEGORY}/binutils-2.20"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

src_unpack() {
	EPATCH_EXCLUDE+="
		94_all_pr57777-O3-avx2.patch
		97_all_native-ivybridge-haswell.patch
		33_all_gcc48_config_rs6000.patch"

	if has_version '<sys-libs/glibc-2.12' ; then
		ewarn "Your host glibc is too old; disabling automatic fortify."
		ewarn "Please rebuild gcc after upgrading to >=glibc-2.12 #362315"
		EPATCH_EXCLUDE+=" 10_all_default-fortify-source.patch"
	fi

	toolchain_src_unpack

	use vanilla && return 0
	#Use -r1 for newer piepatchet that use DRIVER_SELF_SPECS for the hardened specs.
	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env-r1.patch
}

pkg_setup() {
	toolchain_pkg_setup

	if use lto ; then
		ewarn
		ewarn "LTO support is still experimental and unstable.  Any bug reports"
		ewarn "about LTO that do not include an upstream patch will be closed as"
		ewarn "invalid."
		ewarn
	fi
}

src_install() {
	toolchain_src_install

	find "${D}/${LIBPATH}" \( -name libasan.la -o -name libtsan.la \) -exec rm '{}' \;
}

pkg_postinst() {
	toolchain_pkg_postinst

	elog
	elog "Packages failing to build with GCC 4.8 are tracked at"
	elog "https://bugs.gentoo.org/461954"
	elog
}