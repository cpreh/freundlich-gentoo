# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

ESVN_REPO_URI="https://pcsxr.svn.codeplex.com/svn/pcsxr"

inherit autotools eutils subversion

DESCRIPTION="PCSX-Reloaded is a PlayStation Emulator based on PCSX-df 1.9, with
support for Windows, GNU/Linux and Mac OS X as well as many bugfixes and
improvements."
HOMEPAGE="http://www.codeplex.com/pcsxr"
#SRC_URI="http://supraverse.net/freundlich/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+alsa libcdio nls +opengl oss pulseaudio sdl static-libs"
REQUIRED_USE="^^ ( alsa oss pulseaudio sdl )"

DEPEND="
	alsa? (
		media-libs/alsa-lib
	)
	libcdio? (
		dev-libs/libcdio
	)
	opengl? (
		virtual/opengl
		x11-libs/libXxf86vm
	)
	!opengl? (
		x11-libs/libXv	
	)
	oss? (
		media-libs/alsa-oss
	)
	pulseaudio? (
		media-sound/pulseaudio
	)
	sdl? (
		media-libs/libsdl[audio]
	)
	gnome-base/libglade
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
	use alsa && soundbackend="alsa"
	use oss && soundbackend="oss"
	use pulseaudio && soundbackend="pulseaudio"
	use sdl && soundbackend="sdl"

	econf \
		--enable-sound="${soundbackend}" \
		$(use_enable libcdio) \
		$(use_enable nls) \
		$(use_enable opengl) \
		$(use_enable static-libs static)
}
