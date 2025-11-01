# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8
PYTHON_COMPAT=( python3_{11..13} )
inherit python-any-r1 toolchain-funcs qmake-utils

MY_PV="${PV/.}"

DESCRIPTION="Multiple Arcade Machine Emulator + Multi Emulator Super System (MESS)"
HOMEPAGE="http://mamedev.org/"
SRC_URI="https://github.com/mamedev/mame/archive/mame${MY_PV}.tar.gz"

LICENSE="GPL-2+ BSD-2 MIT CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa debug openmp pipewire pcap pulseaudio tools"

#=dev-cpp/asio-1.11*
RDEPEND="
	app-arch/zstd
	dev-libs/expat
	dev-libs/libutf8proc:=
	dev-libs/pugixml
	dev-libs/rapidjson
	media-libs/fontconfig
	media-libs/flac
	media-libs/glm
	media-libs/libsdl2[joystick,opengl,sound,threads(+),video,X]
	media-libs/sdl2-ttf
	sys-libs/zlib
	virtual/jpeg:0
	virtual/opengl
	>=dev-db/sqlite-3
	alsa? ( media-libs/alsa-lib
		media-libs/portaudio
		media-libs/portmidi )
	debug? ( dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5 )
	pcap? ( net-libs/libpcap )
	pulseaudio? ( media-libs/libpulse )
	pipewire? ( media-video/pipewire )
	x11-libs/libX11
	x11-libs/libXinerama
	${PYTHON_DEPS}"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	virtual/pkgconfig
	x11-base/xorg-proto"

S="${WORKDIR}/mame-mame${MY_PV}"

SYSCONFDIR="/etc/${PN}"
DATADIR="/usr/share/${PN}"
BINDIR="/usr/bin"

# Function to disable a makefile option
disable_feature() {
	sed -i -e "/^[ 	]*$1.*=/s:^:# :" makefile || die
}

# Function to enable a makefile option
enable_feature() {
	sed -i -e "/^#.*$1.*=/s:^#[ 	]*::"  makefile || die
}

pkg_setup() {
	python-any-r1_pkg_setup
}

PATCHES=(
	"${FILESDIR}"/${PN}-0.178-qt.patch
)

src_prepare() {
	default
	# Disable using bundled libraries
	enable_feature USE_SYSTEM_LIB_EXPAT
	enable_feature USE_SYSTEM_LIB_FLAC
	enable_feature USE_SYSTEM_LIB_JPEG
	enable_feature USE_SYSTEM_LIB_SQLITE3
# Use bundled lua for now to ensure correct compilation (ref. b.g.o #407091)
#	enable_feature USE_SYSTEM_LIB_LUA
	enable_feature USE_SYSTEM_LIB_PORTAUDIO
	enable_feature USE_SYSTEM_LIB_ZSTD
	enable_feature USE_SYSTEM_LIB_ZLIB
	enable_feature USE_SYSTEM_LIB_UTF8PROC

	# Needs old asio
	#enable_feature USE_SYSTEM_LIB_ASIO
	enable_feature USE_SYSTEM_LIB_GLM
	enable_feature USE_SYSTEM_LIB_RAPIDJSON
	enable_feature USE_SYSTEM_LIB_PUGIXML

	# Disable warnings being treated as errors and enable verbose build output
	enable_feature NOWERROR
	enable_feature VERBOSE

	use amd64 && enable_feature PTR64
	use debug && enable_feature DEBUG
	use tools && enable_feature TOOLS
	disable_feature NO_X11 # bgfx needs X
	use openmp && enable_feature OPENMP

	if use alsa ; then
		enable_feature USE_SYSTEM_LIB_PORTMIDI
	else
		enable_feature NO_USE_MIDI
		enable_feature NO_USE_PORTAUDIO
	fi

	use pcap && enable_feature USE_PCAP

	! use pulseaudio && enable_feature NO_USE_PULSEAUDIO

	! use pipewire && enable_feature NO_USE_PIPEWIRE

	sed -i \
		-e 's/-Os//' \
		-e '/^\(CC\|CXX\|AR\) /s/=/?=/' \
		3rdparty/genie/build/gmake.linux/genie.make || die
}

src_compile() {
	local targetargs="SUBTARGET=mame"
	local qtdebug=$(usex debug 1 0)

	function my_emake() {
		# Workaround conflicting $ARCH variable used by both Gentoo's
		# portage and by Mame's build scripts
		PYTHON_EXECUTABLE=${PYTHON} \
		OVERRIDE_CC=$(tc-getCC) \
		OVERRIDE_CXX=$(tc-getCXX) \
		OVERRIDE_LD=$(tc-getCXX) \
		QT_HOME="$(qt5_get_libdir)/qt5" \
		ARCH= \
			emake "$@" \
				AR=$(tc-getAR)
	}
	my_emake -j1 generate

	my_emake ${targetargs} \
		INI_PATH="\$\$\$\$HOME/.sdlmame;${SYSCONFDIR}" \
		USE_QTDEBUG=${qtdebug}

	if use tools ; then
		my_emake -j1 TARGET=ldplayer USE_QTDEBUG=${qtdebug}
	fi
}

src_install() {
	local MAMEBIN
	local suffix="$(use debug && echo d)"
	local f

	MAMEBIN="mame${suffix}"
	doman docs/man/mame.6
	newman docs/man/mame.6 ${PN}.6
	dobin ${MAMEBIN}
	dosym ${MAMEBIN} "${BINDIR}/${PN}"

	insinto "${DATADIR}"
	doins -r keymaps $(echo hash)

	# Create default mame.ini and inject Gentoo settings into it
	#  Note that '~' does not work and '$HOME' must be used
	./${MAMEBIN} -noreadconfig -showconfig > "${T}/mame.ini" || die
	# -- Paths --
	for f in {rom,hash,sample,art,font,crosshair} ; do
		sed -i \
			-e "s:\(${f}path\)[ \t]*\(.*\):\1 \t\t\$HOME/.${PN}/\2;${DATADIR}/\2:" \
			"${T}/mame.ini" || die
	done
	for f in {ctrlr,cheat} ; do
		sed -i \
			-e "s:\(${f}path\)[ \t]*\(.*\):\1 \t\t\$HOME/.${PN}/\2;${SYSCONFDIR}/\2;${DATADIR}/\2:" \
			"${T}/mame.ini" || die
	done
	# -- Directories
	for f in {cfg,nvram,memcard,input,state,snapshot,diff,comment} ; do
		sed -i \
			-e "s:\(${f}_directory\)[ \t]*\(.*\):\1 \t\t\$HOME/.${PN}/\2:" \
			"${T}/mame.ini" || die
	done
	# -- Keymaps --
	sed -i \
		-e "s:\(keymap_file\)[ \t]*\(.*\):\1 \t\t\$HOME/.${PN}/\2:" \
		"${T}/mame.ini" || die
	for f in keymaps/km*.map ; do
		sed -i \
			-e "/^keymap_file/a \#keymap_file \t\t${DATADIR}/keymaps/${f##*/}" \
			"${T}/mame.ini" || die
	done
	insinto "${SYSCONFDIR}"
	doins "${T}/mame.ini"

	insinto "${SYSCONFDIR}"
	doins "${FILESDIR}/vector.ini"

	keepdir \
		"${DATADIR}"/{ctrlr,cheat,roms,samples,artwork,crosshair} \
		"${SYSCONFDIR}"/{ctrlr,cheat}

	if use tools ; then
		for f in castool chdman floptool imgtool jedutil ldresample ldverify romcmp ; do
			newbin ${f} ${PN}-${f}
			newman docs/man/${f}.1 ${PN}-${f}.1
		done
		newbin ldplayer${suffix} ${PN}-ldplayer
		newman docs/man/ldplayer.1 ${PN}-ldplayer.1
	fi
}

pkg_postinst() {
	elog "It is strongly recommended to change either the system-wide"
	elog "  ${SYSCONFDIR}/mame.ini or use a per-user setup at ~/.${PN}/mame.ini"
	elog
}
