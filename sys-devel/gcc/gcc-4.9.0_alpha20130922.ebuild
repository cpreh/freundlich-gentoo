# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.8.0.ebuild,v 1.8 2013/05/19 14:12:15 blueness Exp $

I_PROMISE_TO_SUPPLY_PATCHES_WITH_BUGS=1
RESTRICT="mirror"

# Hardened gcc 4 stuff
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
PIE_GLIBC_STABLE="x86 amd64 mips ppc ppc64 arm ia64"
PIE_UCLIBC_STABLE="x86 arm amd64 mips ppc ppc64"
SSP_STABLE="amd64 x86 mips ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
# uclibc need to be >= 0.9.33
SSP_UCLIBC_STABLE="x86 amd64 mips ppc ppc64 arm"
#end Hardened stuff

inherit toolchain

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"

KEYWORDS=""

RDEPEND=""
DEPEND="${RDEPEND}
	elibc_glibc? ( >=sys-libs/glibc-2.8 )
	>=${CATEGORY}/binutils-2.20"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

src_unpack() {
	toolchain_src_unpack

	use vanilla && return 0

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

	find "${D}/${LIBPATH}" \( -name libasan.la -o -name libtsan.la -o -name libubsan.la \) -exec rm '{}' \;
}

pkg_postinst() {
	toolchain_pkg_postinst
}
