# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="extractor wrappers for the deco program"
HOMEPAGE="http://hartlich.com/deco/archive/"
SRC_URI="http://hartlich.com/deco/archive/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="app-arch/deco"

src_unpack()
{
	unpack ${A}
	cd "${S}"
	epatch "$FILESDIR/destdir-fix.patch"
}

src_install()
{
	emake DESTDIR="${D}" install || die "Install failed"
}
