# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

RESTRICT="mirror"

inherit autotools base git

MY_P=Arabica

EGIT_REPO_URI="git://github.com/ashb/Arabica.git"

EAPI="3"
DESCRIPTION="An XML parser toolkit written in C++"
HOMEPAGE="http://www.jezuk.co.uk/cgi-bin/view/arabica"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples expat static-libs test xerces-c xml2"
S="${WORKDIR}"/"${MY_P}"

DEPEND="
	expat? ( >=dev-libs/expat-1.95.8 )
	xerces-c? ( >=dev-libs/xerces-c-2.7.0 )
	xml2? ( >=dev-libs/libxml2-2.6.20-r2 )"

pkg_setup() {
	local count=0
	for i in expat xerces-c xml2 ; do
		use ${i} && ((++count))
	done

	[[ count -ne 1 ]] && die "you have to enable exactly one use flag!"
}

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		"--with-boost=no " \
		$(use_with examples dom) \
		$(use_with expat expat) \
		$(use_enable static-libs static) \
		$(use_with xerces-c xerces) \
		$(use_with test tests) \
		$(use_with xml2 libxml2)
}
