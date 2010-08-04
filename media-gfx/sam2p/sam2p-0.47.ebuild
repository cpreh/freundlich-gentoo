# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/sam2p/sam2p-0.47.ebuild,v 1.1 2010/06/11 20:21:57 aballier Exp $

EAPI="2"

inherit toolchain-funcs eutils autotools

DESCRIPTION="Utility to convert raster images to EPS, PDF and many others"
HOMEPAGE="http://code.google.com/p/sam2p/"
SRC_URI="http://sam2p.googlecode.com/files/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="examples gif"

DEPEND="dev-lang/perl"
RDEPEND=""

RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-0.45-fbsd.patch"
	epatch "${FILESDIR}/${PN}-0.45-nostrip.patch"
	epatch "${FILESDIR}/${PN}-0.45-cflags.patch"
	eautoreconf
}

src_prepare() {
	# The build process is totally broken.
	# StdAfx.h contains windows stuff, but it is included as stdafx.h
	# So create an empty stdafx.h. :/
	# bts2.tth is produced during the build process but needed for make depend.
	# It contains no source code, so it can be created as an empty file at first.
	touch "${S}"/stdafx.h
	touch "${S}"/bts2.tth
}

src_configure() {
	tc-export CXX
	econf --enable-lzw $(use_enable gif) || die "econf failed"
}

src_compile() {
	tc-export CXX
	emake || die "make failed"
}

src_install() {
	dobin sam2p || die "Failed to install sam2p"
	dodoc README
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi
}
