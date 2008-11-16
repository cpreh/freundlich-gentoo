# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git

DESCRIPTION="minimalistic irc bot to post commit messages to irc"
HOMEPAGE="none"
EGIT_REPO_URI="git://localhost/gitbot.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
#EAPI="paludis-1"

RDEPEND="net-libs/slirc
         dev-libs/boost"
DEPEND="${RDEPEND}
        dev-util/cmake"

src_unpack() {
	git_src_unpack
	cd "${S}"
}

src_compile() {
	cmake \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		-DCMAKE_INSTALL_PREFIX=/usr \
		. || die "cmake failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR=${D} install || die "emake install failed"
}
