# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/suds/suds-0.4.ebuild,v 1.2 2011/04/05 07:43:18 angelos Exp $

EAPI="3"
PYTHON_DEPEND="2 3"
SUPPORT_PYTHON_ABIS="1"
#RESTRICT_PYTHON_ABIS="3.*"
RESTRICT_PYTHON_ABIS=""

inherit distutils

DESCRIPTION="2D planar geometry library for Python"
HOMEPAGE="http://pypi.python.org/pypi/planar/0.1"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND=""

src_compile() {
	distutils_src_compile
}

src_install() {
	distutils_src_install
}
