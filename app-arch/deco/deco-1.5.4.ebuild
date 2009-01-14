# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="deco is a program able to extract various archive file formats"
HOMEPAGE="http://hartlich.com/deco/"
SRC_URI="http://hartlich.com/deco/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack()
{
	unpack ${A}
	cd "${S}"
	epatch "$FILESDIR/destdir-fix.patch" || die "Patch failed"
}

src_install()
{
	emake DESTDIR="${D}" install || die "Install failed"
}
