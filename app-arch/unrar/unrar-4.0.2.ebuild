# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/unrar/unrar-4.0.2.ebuild,v 1.1 2010/12/13 10:12:50 vapier Exp $

EAPI=2

inherit eutils toolchain-funcs

MY_PN=${PN}src
DESCRIPTION="Uncompress rar files"
HOMEPAGE="http://www.rarlab.com/rar_add.htm"
SRC_URI="http://www.rarlab.com/rar/${MY_PN}-${PV}.tar.gz"

LICENSE="unRAR"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

DEPEND="!<=app-arch/unrar-gpl-0.0.1_p20080417"

S=${WORKDIR}/unrar

src_prepare() {
	epatch "${FILESDIR}"/interactivity-${PV}.patch
}

src_compile() {
	emake \
		-f makefile.unix \
		CXXFLAGS="${CXXFLAGS}" \
		CXX="$(tc-getCXX)" \
		STRIP="true" || die "emake failed"
}

src_install() {
	dobin unrar || die
	dodoc readme.txt
}
