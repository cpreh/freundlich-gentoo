# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

RESTRICT="mirror"

inherit autotools eutils games

DESCRIPTION="PCSX-Reloaded is a PlayStation Emulator based on PCSX-df 1.9, with
support for Windows, GNU/Linux and Mac OS X as well as many bugfixes and
improvements."
HOMEPAGE="http://www.codeplex.com/pcsxr"
SRC_URI="http://supraverse.net/freundlich/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+alsa nls +opengl"

DEPEND="
	alsa? (
		media-libs/alsa-lib
	)
	!alsa? (
		media-libs/alsa-oss
	)
	opengl? (
		virtual/opengl
		x11-libs/libXxf86vm
	)
	!opengl? (
		x11-libs/libXv	
	)
	gnome-base/libglade
	media-libs/alsa-lib
	media-libs/libsdl
	sys-libs/zlib
	>=x11-libs/gtk+-2
	x11-libs/libX11
	x11-libs/libXext
	|| ( >=x11-libs/libXtst-1.1.0 <x11-proto/xextproto-7.1.0 )
	"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable alsa) \
		$(use_enable nls) \
		$(use_enable opengl) \
		--disable-sdltest
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
}
