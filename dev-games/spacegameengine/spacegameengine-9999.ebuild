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
IUSE="+alda +audio audio_null +camera +charconv +cg +config +console +devil doc
examples evdev +font +fontbitmap +fonttext +freetype +image +image2d +image3d
+input +line_drawer +log +media modelmd3 modelobj +openal opencl +opengl +parse
+plugin +png projectile +renderer +rendereropengl +sprite +systems test +texture
+timer +viewport +vorbis +wave +window +x11input +xrandr"

RDEPEND="
	~dev-cpp/fcppt-9999
	~dev-cpp/mizuiro-9999
	~dev-cpp/libawl-9999
	>=dev-libs/boost-1.47.0
	cg? (
		>=media-gfx/nvidia-cg-toolkit-3
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
		media-libs/glew
		x11-libs/libX11
		virtual/opengl
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
	check_deps audio log media plugin
	check_deps audio_null audio plugin
	check_deps camera input renderer viewport
	#check_deps cegui charconv image image2d input renderer viewport
	check_deps console fonttext input sprite
	check_deps devil image image2d log plugin
	check_deps evdev input log plugin window
	check_deps font plugin
	check_deps fontbitmap font image2d log parse
	check_deps fonttext font image image2d renderer sprite texture
	check_deps freetype charconv font image2d log plugin
	check_deps image2d image media plugin
	check_deps image3d image
	check_deps input plugin
	check_deps line_drawer image renderer
	check_deps media log
	check_deps modelmd3 log
	check_deps openal audio log plugin
	check_deps opencl image image2d log renderer rendereropengl
	check_deps opengl image image2d image3d log plugin renderer rendereropengl
	check_deps png image image2d log plugin
	check_deps projectile image line_drawer log renderer
	check_deps renderer image image2d image3d log plugin
	check_deps sprite image renderer
	check_deps systems audio charconv config font image2d input log renderer \
		viewport window
	check_deps texture image2d log renderer
	check_deps viewport renderer window
	check_deps vorbis audio log plugin
	check_deps wave audio plugin
	check_deps x11input input log plugin window

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
		$(cmake-utils_use_enable cg)
		$(cmake-utils_use_enable charconv)
		$(cmake-utils_use_enable config)
		$(cmake-utils_use_enable console)
		$(cmake-utils_use_enable devil)
		$(cmake-utils_use_enable doc)
		$(cmake-utils_use_enable examples)
		$(cmake-utils_use_enable evdev)
		$(cmake-utils_use_enable font)
		$(cmake-utils_use_enable fontbitmap)
		$(cmake-utils_use_enable fonttext)
		$(cmake-utils_use_enable freetype)
		$(cmake-utils_use_enable image)
		$(cmake-utils_use_enable image2d)
		$(cmake-utils_use_enable image3d)
		$(cmake-utils_use_enable input)
		$(cmake-utils_use_enable line_drawer)
		$(cmake-utils_use_enable log)
		$(cmake-utils_use_enable media)
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
		$(cmake-utils_use_enable sprite)
		$(cmake-utils_use_enable systems)
		$(cmake-utils_use_enable test)
		$(cmake-utils_use_enable texture)
		$(cmake-utils_use_enable timer)
		$(cmake-utils_use_enable viewport)
		$(cmake-utils_use_enable vorbis)
		$(cmake-utils_use_enable window)
		$(cmake-utils_use_enable wave)
		$(cmake-utils_use_enable x11input)
		$(cmake-utils_use_enable xrandr)
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
