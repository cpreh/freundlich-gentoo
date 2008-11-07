# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion

ESVN_REPO_URI="https://id3rem.svn.sourceforge.net/svnroot/id3rem"

DESCRIPTION="A very simple id3 remover"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="${RDEPEND}
        dev-util/scons"
RDEPEND="dev-libs/boost"

src_unpack() {
	subversion_src_unpack
	cd ${S}
}

src_compile() {
	scons destdir=${D} cxxflags="${CXXFLAGS}" || die
}

src_install() {
	scons install destdir=${D} cxxflags="${CXXFLAGS}" || die
}
