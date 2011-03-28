# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/libwpd/libwpd-0.8.14.ebuild,v 1.10 2010/01/02 11:28:27 fauli Exp $

EAPI="2"

inherit eutils

DESCRIPTION="WordPerfect Document import/export library"
HOMEPAGE="http://libwpd.sf.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"
RESTRICT="test"

RDEPEND=">=dev-libs/glib-2
	>=gnome-extra/libgsf-1.6"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-doc/doxygen )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-gcc46.patch
}

src_configure() {
	econf $(use_with doc docs)
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "installation failed"
	dodoc CHANGES CREDITS INSTALL README TODO
}
