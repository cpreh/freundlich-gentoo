# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Made by LlulluTuqo
# $Header: /var/cvsroot/gentoo-x86/games-strategy/glest/glest-3.2.2.ebuild,v 1.9 2010/08/15 21:03:02 ssuominen Exp $

RESTRICT="mirror"

EAPI=3

inherit eutils wxwidgets games cmake-utils

DESCRIPTION="Cross-platform 3D realtime strategy game"
HOMEPAGE="http://www.glest.org/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-source-3.5.0.tar.bz2
	mirror://sourceforge/${PN}/${PN}-data-3.5.0.1.7z"

LICENSE="GPL-2 glest-data"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="media-libs/libsdl[joystick,video]
	media-libs/libogg
	media-libs/libvorbis
	media-libs/openal
	>dev-libs/xerces-c-3
	>=net-misc/curl-7.21.0
	virtual/opengl
	virtual/glu
	dev-lang/lua
	x11-libs/libX11
	x11-libs/wxGTK:2.8[X]"
DEPEND="${RDEPEND}
	app-arch/p7zip"

S="${WORKDIR}"/${PN}-source-${PV}

src_prepare() {
	epatch "${FILESDIR}"/${P}-gentoo.patch
	epatch "${FILESDIR}"/${P}-no-static-curl.patch

	sed -i \
	-e "s:@GENTOO_DATADIR@:${GAMES_DATADIR}/${PN}:" \
	source/glest_game/main/main.cpp \
	|| die "sed failed"

	sed -i \
	-e '/Lang/s:\.lng::' \
	glest.ini \
	|| die "sed failed"
}

src_configure() {
	cd "${S}"
	WX_GTK_VER=2.8
	need-wxwidgets unicode

	local mycmakeargs="-D WANT_SVN_STAMP=OFF"

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cd "${S}"
	insinto "${GAMES_DATADIR}"/${PN}
	doins glest.ini || die

	cd "${WORKDIR}"
	doins glestkeys.ini || die

	doins -r  servers.ini \
		data maps scenarios techs tilesets tutorials || die
	dodoc docs/README || die

	cd "${S}"
	dogamesbin mk/linux/megaglest.bin || die
	dogamesbin mk/linux/megaglest_editor || die
	dogamesbin mk/linux/megaglest_g3dviewer || die
	dogamesbin mk/linux/megaglest_configurator || die

	cd "${WORKDIR}"

	newicon techs/megapack/factions/magic/units/archmage/images/archmage.bmp \
		${PN}.bmp || die
	make_desktop_entry glest.bin MegaGlest /usr/share/pixmaps/${PN}.bmp || die
	prepgamesdirs || die
}
