# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils games git

EGIT_REPO_URI="git://github.com/freundlich/spacegameengine.git"

DESCRIPTION="An easy to use game engine written in C++"
HOMEPAGE="http://redmine.supraverse.net/projects/show/sge"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="
audio_null +camera cegui +config +console +devil
examples +fontbitmap +fonttext +iconv +line_drawer md3
+openal +opengl +parse +png projectile +shader +sprite +systems
test +texture +time +truetype +viewport +vorbis +wave +x11input"

DEPEND="
	=dev-cpp/fcppt-scm
	=dev-cpp/mizuiro-scm
	=dev-cpp/libawl-scm
	>=dev-libs/boost-1.46.0
	x11-libs/libX11
	cegui? (
		>=dev-games/cegui-0.7.5
	)
	devil? (
		media-libs/devil
	)
	iconv? (
		virtual/libiconv
	)
	openal? (
		media-libs/openal
	)
	opengl? (
		=dev-cpp/libawl-scm[opengl]
		virtual/opengl
	)
	png? (
		media-libs/libpng
	)
	projectile? (
		sci-physics/bullet
	)
	truetype? (
		media-libs/freetype
	)
	vorbis? (
		media-libs/libvorbis
	)
"
RDEPEND="${DEPEND}"

#REQUIRED_USE="
#	cegui? ( time )
#	config? ( parse )
#	console? ( fonttext time )
#	fontbitmap? ( parse )
#	fonttext? ( sprite texture )
#	projectile? ( line_drawer )
#	systems? ( config viewport )
#	x11input? ( time )
#"

check_deps() {
	if use $1 ; then
		for i in ${@:2} ; do
			if ! use ${i} ; then
				local die_message="${i} is required for $1"
				eerror "${die_message}"
				die "${die_message}"
			fi
		done
	fi
}

pkg_setup() {
	check_deps cegui time
	check_deps config parse
	check_deps console fonttext time
	check_deps fontbitmap parse
	check_deps fonttext sprite texture
	check_deps projectile line_drawer
	check_deps systems config viewport
	check_deps x11input time
}

src_configure() {
	local mycmakeargs=(
		-D CMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-D INSTALL_DATA_DIR_BASE="${GAMES_DATADIR}"
		-D INSTALL_LIBRARY_DIR=$(games_get_libdir)
		-D INSTALL_CMAKEMODULES_DIR="/usr/share/cmake/Modules"
		$(cmake-utils_use_enable audio_null)
		$(cmake-utils_use_enable camera)
		$(cmake-utils_use_enable cegui)
		$(cmake-utils_use_enable config)
		$(cmake-utils_use_enable console)
		$(cmake-utils_use_enable devil)
		$(cmake-utils_use_enable examples)
		$(cmake-utils_use_enable fontbitmap)
		$(cmake-utils_use_enable fonttext)
		$(cmake-utils_use_enable iconv)
		$(cmake-utils_use_enable line_drawer)
		$(cmake-utils_use_enable md3)
		$(cmake-utils_use_enable openal)
		$(cmake-utils_use_enable opengl)
		$(cmake-utils_use_enable parse)
		$(cmake-utils_use_enable png)
		$(cmake-utils_use_enable projectile)
		$(cmake-utils_use_enable shader)
		$(cmake-utils_use_enable sprite)
		$(cmake-utils_use_enable systems)
		$(cmake-utils_use_enable test)
		$(cmake-utils_use_enable texture)
		$(cmake-utils_use_enable time)
		$(cmake-utils_use_enable truetype)
		$(cmake-utils_use_enable viewport)
		$(cmake-utils_use_enable vorbis)
		$(cmake-utils_use_enable wave)
		$(cmake-utils_use_enable x11input)
		-D BULLET_INCLUDE_DIR=/usr/include/bullet
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install

	prepgamesdirs
}
