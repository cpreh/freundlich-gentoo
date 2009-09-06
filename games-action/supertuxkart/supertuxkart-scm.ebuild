# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-action/supertuxkart/supertuxkart-0.6.2.ebuild,v 1.2 2009/09/02 13:21:28 nyhm Exp $

EAPI=2
inherit autotools eutils games subversion

DESCRIPTION="A kart racing game starring Tux, the linux penguin (TuxKart fork)"
HOMEPAGE="http://supertuxkart.sourceforge.net/"

ESVN_REPO_URI="https://supertuxkart.svn.sourceforge.net/svnroot/supertuxkart/main/trunk"

LICENSE="GPL-3 CCPL-Attribution-ShareAlike-3.0 CCPL-Attribution-2.0 CCPL-Sampling-Plus-1.0 public-domain as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND=">=media-libs/plib-1.8.4
	virtual/opengl
	virtual/glut
	virtual/glu
	net-libs/enet
	media-libs/libmikmod
	media-libs/libvorbis
	media-libs/openal
	media-libs/libsdl[X,video,audio,joystick]"

src_prepare() {
	esvn_clean
	sed -i \
		-e '/ENETTREE/d' \
		-e '/src\/enet\/Makefile/d' \
		configure.ac \
		|| die "sed failed"
	sed -i \
		-e '/SUBDIRS/s/doc//' \
		-e '/pkgdata/d' \
		Makefile.am \
		|| die "sed failed"
	sed -i \
		-e '/pkgdatadir/s:/games::' \
		-e '/desktop/d' \
		-e '/icon/d' \
		$(find data -name Makefile.am) \
		|| die "sed failed"
	sed -i \
		-e '/bindir/d' \
		-e '/AM_CPPFLAGS/s:/games::' \
		src/Makefile.am \
		|| die "sed failed"
	rm -rf src/enet
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	doicon "${DISTDIR}"/${PN}.png
	make_desktop_entry ${PN} SuperTuxKart
	dodoc AUTHORS ChangeLog README TODO
	prepgamesdirs
}
