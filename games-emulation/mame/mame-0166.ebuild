# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )

RESTRICT="mirror"

inherit eutils games python-any-r1

DESCRIPTION="Multiple Arcade Machine Emulator"
HOMEPAGE="http://mamedev.org"
SRC_URI="http://mamedev.org/downloader.php?file=${PN}${PV}/${PN}${PV}s.zip"

LICENSE="XMAME"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

#>=dev-lang/lua-5.3

RDEPEND="
	dev-db/sqlite
	dev-libs/expat
	media-libs/flac
	media-libs/fontconfig
	media-libs/alsa-lib
	media-libs/portaudio
	media-libs/portmidi
	media-libs/libsdl2[X,alsa,joystick,opengl,sound,threads,video]
	media-libs/sdl2-ttf[X]
	sys-libs/zlib
	virtual/jpeg:0
	virtual/opengl
	x11-libs/libX11
"
DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
"

S=${WORKDIR}

set_feature() {
	sed -i \
		"s/^#.*$1.*$/$1 = $2/g"  \
		"${S}"/makefile \
		|| die "sed failed"
}

enable_feature() {
	set_feature "$1" 1
}

disable_feature() {
	set_feature "$1" 0
}

pkg_setup() {
	games_pkg_setup
	python-any-r1_pkg_setup
}

src_unpack() {
	default
	unpack ./mame.zip
	rm -f mame.zip
}

src_prepare() {
	edos2unix makefile
}

src_configure() {
	enable_feature USE_SYSTEM_LIB_EXPAT
	enable_feature USE_SYSTEM_LIB_ZLIB
	enable_feature USE_SYSTEM_LIB_JPEG
	enable_feature USE_SYSTEM_LIB_FLAC
	#enable_feature USE_SYSTEM_LIB_LUA
	enable_feature USE_SYSTEM_LIB_SQLITE3
	enable_feature USE_SYSTEM_LIB_PORTMIDI
	enable_feature USE_SYSTEM_LIB_PORTAUDIO

	disable_feature USE_QTDEBUG
}

src_compile() {
	unset ARCH
	default
}

src_install() {
	newgamesbin ${PN}$(use amd64 && echo 64) ${PN}
}

pkg_postinst() {
	games_pkg_postinst
}
