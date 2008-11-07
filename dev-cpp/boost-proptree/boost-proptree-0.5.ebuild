# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="To be reviewed boost property tree class"
HOMEPAGE="http://www.boost-consulting.com/vault/"
SRC_URI="property_tree_rev5.zip"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND="dev-libs/boost"

src_install()
{
	dodir "/usr/include/boost"
	cp -R ${WORKDIR}/boost/property_tree "${D}usr/include/boost/" || die "Install failed!"
}
