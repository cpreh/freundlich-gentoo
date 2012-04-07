# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils git games

EGIT_REPO_URI="git://github.com/freundlich/spacegameengine.git"

DESCRIPTION="An easy to use game engine written in C++"
HOMEPAGE="http://freundlich.github.com/spacegameengine/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+alda +audio audio_null +camera cegui +charconv +config +console +devil
doc examples +font +fontbitmap +fonttext +freetype +image +image2d +image3d
+input +line_drawer modelmd3 modelobj +openal opencl +opengl +parse +plugin +png
projectile +renderer +rendereropengl +shader +sprite +systems test +texture
+viewport +vorbis +wave +window xf86vmode +x11input xrandr"

RDEPEND="
	=dev-cpp/fcppt-9999
	=dev-cpp/mizuiro-9999
	=dev-cpp/libawl-9999
	>=dev-libs/boost-1.47.0
	cegui? (
		>=dev-games/cegui-0.7.5
		examples? (
			>=dev-games/cegui-0.7.5[truetype,xml]
		)
	)
	charconv? (
		virtual/libiconv
	)
	devil? (
		media-libs/devil
	)
	freetype? (
		media-libs/freetype
	)
	openal? (
		media-libs/openal
	)
	opencl? (
		dev-util/nvidia-cuda-sdk[opencl]
	)
	opengl? (
		=dev-cpp/libawl-9999[opengl]
		media-libs/glew
		x11-libs/libX11
		virtual/opengl
		xf86vmode? (
			x11-libs/libXxf86vm
		)
		xrandr? (
			x11-libs/libXrandr
		)
	)
	png? (
		media-libs/libpng
	)
	projectile? (
		sci-physics/bullet
	)
	vorbis? (
		media-libs/libvorbis
	)
	x11input? (
		x11-libs/libXi
		x11-libs/libX11
	)
"
#for doxygen formulas, 'latex', 'dvips' and 'gs' are needed
DEPEND+="
	${RDEPEND}
	doc? (
		>=app-doc/doxygen-1.7.5
		app-text/dvipsk
		app-text/ghostscript-gpl
		dev-texlive/texlive-latex
	)
"

exit_sge_build=false

check_deps() {
	if use $1 ; then
		for i in ${@:2} ; do
			if ! use ${i} ; then
				eerror "${i} is required for $1"
				exit_sge_build=true
			fi
		done
	fi
}

pkg_setup() {
	check_deps audio plugin
	check_deps audio_null audio
	check_deps camera input renderer
	check_deps cegui charconv image image2d input renderer viewport
	check_deps console fonttext input
	check_deps devil image2d
	check_deps font plugin
	check_deps fontbitmap parse
	check_deps fonttext sprite texture
	check_deps freetype charconv font image2d
	check_deps image2d image plugin
	check_deps image2d image
	check_deps input plugin
	check_deps line_drawer renderer
	check_deps openal audio
	check_deps opencl rendereropengl
	check_deps opengl image2d image3d plugin renderer rendereropengl
	check_deps png image2d
	check_deps projectile line_drawer
	check_deps renderer image2d image3d plugin
	check_deps shader renderer
	check_deps sprite renderer
	check_deps systems audio charconv config font image2d input renderer \
		viewport window
	check_deps texture image2d renderer
	check_deps viewport window
	check_deps vorbis audio
	check_deps wave audio
	check_deps x11input input window

	if ${exit_sge_build} ; then
		die "Use dependencies not met"
	fi
}

src_unpack() {
	git_src_unpack
}

src_configure() {
	# Libs and includes go to the normal destination (/usr)
	# Everything else should go into the games dir (examples and media)
	local mycmakeargs=(
		-D INSTALL_DATA_DIR_BASE="${GAMES_DATADIR}"
		-D INSTALL_BINARY_DIR="${GAMES_BINDIR}"
		-D INSTALL_PLUGIN_DIR_BASE=$(games_get_libdir)
		-D INSTALL_DOC_DIR_BASE="/usr/share/doc"
		-D CHARCONV_BACKEND="iconv"
		$(cmake-utils_use_enable alda)
		$(cmake-utils_use_enable audio)
		$(cmake-utils_use_enable audio_null)
		$(cmake-utils_use_enable camera)
		$(cmake-utils_use_enable cegui)
		$(cmake-utils_use_enable charconv)
		$(cmake-utils_use_enable config)
		$(cmake-utils_use_enable console)
		$(cmake-utils_use_enable devil)
		$(cmake-utils_use_enable doc)
		$(cmake-utils_use_enable examples)
		$(cmake-utils_use_enable font)
		$(cmake-utils_use_enable fontbitmap)
		$(cmake-utils_use_enable fonttext)
		$(cmake-utils_use_enable freetype)
		$(cmake-utils_use_enable image)
		$(cmake-utils_use_enable image2d)
		$(cmake-utils_use_enable image3d)
		$(cmake-utils_use_enable input)
		$(cmake-utils_use_enable line_drawer)
		$(cmake-utils_use_enable modelmd3)
		$(cmake-utils_use_enable modelobj)
		$(cmake-utils_use_enable openal)
		$(cmake-utils_use_enable opencl)
		$(cmake-utils_use_enable opengl)
		$(cmake-utils_use_enable parse)
		$(cmake-utils_use_enable plugin)
		$(cmake-utils_use_enable png)
		$(cmake-utils_use_enable projectile)
		$(cmake-utils_use_enable renderer)
		$(cmake-utils_use_enable rendereropengl)
		$(cmake-utils_use_enable shader)
		$(cmake-utils_use_enable sprite)
		$(cmake-utils_use_enable systems)
		$(cmake-utils_use_enable test)
		$(cmake-utils_use_enable texture)
		$(cmake-utils_use_enable viewport)
		$(cmake-utils_use_enable vorbis)
		$(cmake-utils_use_enable window)
		$(cmake-utils_use_enable wave)
		$(cmake-utils_use_enable x11input)
		$(cmake-utils_use_enable xrandr)
		$(cmake-utils_use_enable xf86vmode)
		-D BULLET_INCLUDE_DIR=/usr/include/bullet
	)

	cmake-utils_src_configure
}

src_compile() {
	local ARGS="all"

	use doc && ARGS+=" doc"

	# don't quote ARGS!
	cmake-utils_src_compile $ARGS
}

src_install() {
	cmake-utils_src_install

	# remove empty directories because doxygen creates them
	find "${D}" -type d -empty -delete || die

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
}

pkg_postinst() {
	games_pkg_postinst
}
