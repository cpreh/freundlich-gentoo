# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/unrar/unrar-4.2.4.ebuild,v 1.14 2013/03/16 15:35:08 vapier Exp $

EAPI=4
inherit flag-o-matic multilib toolchain-funcs eutils

MY_PN=${PN}src

DESCRIPTION="Uncompress rar files"
HOMEPAGE="http://www.rarlab.com/rar_add.htm"
SRC_URI="http://www.rarlab.com/rar/${MY_PN}-${PV}.tar.gz"

LICENSE="unRAR"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~arm-linux ~x86-linux"
IUSE="interactivity"

RDEPEND="!<=app-arch/unrar-gpl-0.0.1_p20080417"

S=${WORKDIR}/unrar

src_prepare() {
	epatch "${FILESDIR}"/${PN}-4.2.4-build.patch
	sed -i \
		-e "/libunrar/s:.so:$(get_libname ${PV%.*.*}):" \
		-e "s:-shared:& -Wl,-soname -Wl,libunrar$(get_libname ${PV%.*.*}):" \
		makefile.unix || die

	if use interactivity ; then
		epatch "${FILESDIR}"/${PN}-interactivity.patch
	fi
}

src_compile() {
	unrar_make() {
		emake -f makefile.unix CXX="$(tc-getCXX)" CXXFLAGS="${CXXFLAGS}" STRIP=true "$@"
	}

	unrar_make CXXFLAGS+=" -fPIC" lib
	ln -s libunrar$(get_libname ${PV%.*.*}) libunrar$(get_libname)
	ln -s libunrar$(get_libname ${PV%.*.*}) libunrar$(get_libname ${PV})

	# The stupid code compiles a lot of objects differently if
	# they're going into a lib (-DRARDLL) or into the main app.
	# So for now, we can't link the main app against the lib.
	unrar_make clean
	unrar_make
}

src_install() {
	dobin unrar
	dodoc readme.txt

	dolib.so libunrar*

	insinto /usr/include/libunrar${PV%.*.*}
	doins *.hpp
	dosym libunrar${PV%.*.*} /usr/include/libunrar
}
