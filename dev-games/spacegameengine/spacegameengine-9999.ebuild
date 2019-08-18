# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

CMAKE_MIN_VERSION="3.0.0"
inherit cmake-utils git-r3

EGIT_REPO_URI="https://github.com/freundlich/spacegameengine.git"

DESCRIPTION="An easy to use game engine written in C++"
HOMEPAGE="http://freundlich.github.com/spacegameengine/"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+X +audio audio_null +camera cegui +cg +charconv +config +console
+consolegfx doc egl examples evdev +font +fontbitmap +fontdraw gui graph +image
+image2d +image3d +imagecolor +imageds +imageds2d +input +line_drawer +log
+media modelmd3 modelobj +openal opencl +opengl +pango +parse +parseini
+parsejson +plugin +png postprocessing projectile +renderer +rendereropengl
resource_tree rucksack rucksackviewport scenic sdl sdlinput +shader +sprite static-libs
+systems test +texture +timer tools +viewport +vorbis +wave wayland +window wlinput +x11input"

RDEPEND="
	~dev-cpp/fcppt-9999
	~dev-cpp/brigand-9999
	>=dev-libs/boost-1.59.0:=
	X? (
		~dev-cpp/libawl-9999[X]
	)
	charconv? (
		dev-libs/boost[nls]
	)
	cegui? (
		>=dev-games/cegui-0.8.0
	)
	cg? (
		>=media-gfx/nvidia-cg-toolkit-3
	)
	examples? (
		~dev-cpp/libawl-9999
	)
	image? (
		~dev-cpp/mizuiro-9999
	)
	openal? (
		media-libs/openal
	)
	opencl? (
		virtual/opencl
	)
	opengl? (
		X? (
			x11-libs/libX11
			x11-libs/libXrandr
		)
		egl? (
			media-libs/mesa[egl]
		)
		sdl? (
			media-libs/libsdl2[opengl]
		)
		wayland? (
			dev-libs/wayland
		)
	)
	pango? (
		media-libs/fontconfig
		media-libs/freetype
		x11-libs/pango
	)
	png? (
		media-libs/libpng
	)
	projectile? (
		sci-physics/bullet
	)
	renderer? (
		~dev-cpp/libawl-9999
	)
	rendereropengl? (
		virtual/opengl
	)
	sdl? (
		~dev-cpp/libawl-9999[sdl]
		media-libs/libsdl2
	)
	sdlinput? (
		media-libs/libsdl2[joystick]
	)
	tools? (
		~dev-cpp/libawl-9999
	)
	vorbis? (
		media-libs/libvorbis
	)
	wayland? (
		~dev-cpp/libawl-9999[wayland]
	)
	window? (
		~dev-cpp/libawl-9999
	)
	wlinput? (
		dev-libs/wayland
		x11-libs/libxkbcommon
	)
	x11input? (
		x11-libs/libXi
		x11-libs/libX11
	)
"
DEPEND="
	${RDEPEND}
	doc? (
		>=app-doc/doxygen-1.7.5[latex]
	)
	test? (
		dev-cpp/catch
	)
"

REQUIRED_USE="
	audio? ( log media plugin )
	audio_null? ( audio plugin )
	camera? ( input log parsejson renderer viewport timer )
	cegui? ( charconv imagecolor image2d input log renderer viewport )
	console? ( font )
	consolegfx? ( console font fontdraw imagecolor input renderer )
	evdev? ( input log plugin window )
	font? ( imagecolor image2d log plugin )
	fontbitmap? ( font imagecolor image2d log parsejson )
	fontdraw? ( font imagecolor image2d renderer sprite texture )
	gui? ( font fontdraw imagecolor input renderer rucksack rucksackviewport sprite texture timer )
	graph? ( image image2d imagecolor renderer sprite texture )
	image2d? ( image imagecolor log media plugin )
	image3d? ( image imagecolor )
	imagecolor? ( image )
	imageds? ( image )
	imageds2d? ( image imageds )
	input? ( log plugin window )
	line_drawer? ( imagecolor renderer )
	media? ( log plugin )
	modelmd3? ( log )
	modelobj? ( charconv imagecolor log renderer )
	openal? ( audio log plugin )
	opencl? ( image2d imagecolor log renderer rendereropengl )
	opengl? ( image2d image3d imagecolor imageds imageds2d log plugin renderer rendereropengl )
	pango? ( charconv font image2d imagecolor plugin )
	parseini? ( parse )
	parsejson? ( parse )
	plugin? ( log )
	png? ( image image2d imagecolor log media plugin )
	postprocessing? ( cg config imagecolor renderer shader viewport )
	projectile? ( imagecolor line_drawer log renderer )
	renderer? ( image2d image3d imagecolor imageds imageds2d log plugin )
	rucksackviewport? ( renderer rucksack viewport )
	scenic? ( camera cg charconv config imagecolor image2d line_drawer modelobj parsejson renderer shader viewport )
	sdlinput? ( sdl )
	shader? ( cg renderer )
	sprite? ( image renderer texture )
	systems? ( audio config font image2d input log media parse parseini plugin renderer sprite texture viewport window )
	texture? ( image image2d log renderer )
	viewport? ( renderer window )
	vorbis? ( audio log media plugin )
	wave? ( audio log media plugin )
	x11input? ( X input log plugin window )
	wlinput? ( charconv input log plugin wayland window )
"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_AUDIO="$(usex audio)"
		-D ENABLE_AUDIO_NULL="$(usex audio_null)"
		-D ENABLE_CAMERA="$(usex camera)"
		-D ENABLE_CEGUI="$(usex cegui)"
		-D ENABLE_CG="$(usex cg)"
		-D ENABLE_CHARCONV="$(usex charconv)"
		-D ENABLE_CONFIG="$(usex config)"
		-D ENABLE_CONSOLE="$(usex console)"
		-D ENABLE_CONSOLEGFX="$(usex consolegfx)"
		-D ENABLE_DOC="$(usex doc)"
		-D ENABLE_EXAMPLES="$(usex examples)"
		-D ENABLE_EVDEV="$(usex evdev)"
		-D ENABLE_FONT="$(usex font)"
		-D ENABLE_FONTBITMAP="$(usex fontbitmap)"
		-D ENABLE_FONTDRAW="$(usex fontdraw)"
		-D ENABLE_GUI="$(usex gui)"
		-D ENABLE_GRAPH="$(usex graph)"
		-D ENABLE_IMAGE="$(usex image)"
		-D ENABLE_IMAGE2D="$(usex image2d)"
		-D ENABLE_IMAGE3D="$(usex image3d)"
		-D ENABLE_IMAGECOLOR="$(usex imagecolor)"
		-D ENABLE_IMAGEDS="$(usex imageds)"
		-D ENABLE_IMAGEDS2D="$(usex imageds2d)"
		-D ENABLE_INPUT="$(usex input)"
		-D ENABLE_LINE_DRAWER="$(usex line_drawer)"
		-D ENABLE_LOG="$(usex log)"
		-D ENABLE_MEDIA="$(usex media)"
		-D ENABLE_MODELMD3="$(usex modelmd3)"
		-D ENABLE_MODELOBJ="$(usex modelobj)"
		-D ENABLE_OPENAL="$(usex openal)"
		-D ENABLE_OPENCL="$(usex opencl)"
		-D ENABLE_OPENGL="$(usex opengl)"
		-D ENABLE_OPENGL_EGL="$(usex egl)"
		-D ENABLE_OPENGL_SDL="$(usex sdl)"
		-D ENABLE_OPENGL_WAYLAND="$(usex wayland)"
		-D ENABLE_OPENGL_X11="$(usex X)"
		-D ENABLE_PANGO="$(usex pango)"
		-D ENABLE_PARSE="$(usex parse)"
		-D ENABLE_PARSEINI="$(usex parseini)"
		-D ENABLE_PARSEJSON="$(usex parsejson)"
		-D ENABLE_PLUGIN="$(usex plugin)"
		-D ENABLE_LIBPNG="$(usex png)"
		-D ENABLE_POSTPROCESSING="$(usex postprocessing)"
		-D ENABLE_PROJECTILE="$(usex projectile)"
		-D ENABLE_RENDERER="$(usex renderer)"
		-D ENABLE_RENDEREROPENGL="$(usex rendereropengl)"
		-D ENABLE_RESOURCE_TREE="$(usex resource_tree)"
		-D ENABLE_RUCKSACK="$(usex rucksack)"
		-D ENABLE_RUCKSACKVIEWPORT="$(usex rucksackviewport)"
		-D ENABLE_SCENIC="$(usex scenic)"
		-D ENABLE_SDL="$(usex sdl)"
		-D ENABLE_SDLINPUT="$(usex sdlinput)"
		-D ENABLE_SHADER="$(usex shader)"
		-D ENABLE_SPRITE="$(usex sprite)"
		-D ENABLE_STATIC="$(usex static-libs)"
		-D ENABLE_SYSTEMS="$(usex systems)"
		-D ENABLE_TEST="$(usex test)"
		-D ENABLE_TEXTURE="$(usex texture)"
		-D ENABLE_TIMER="$(usex timer)"
		-D ENABLE_TOOLS="$(usex tools)"
		-D ENABLE_VIEWPORT="$(usex viewport)"
		-D ENABLE_VORBIS="$(usex vorbis)"
		-D ENABLE_WINDOW="$(usex window)"
		-D ENABLE_WAVE="$(usex wave)"
		-D ENABLE_X11INPUT="$(usex x11input)"
		-D ENABLE_WLINPUT="$(usex wlinput)"
	)

	cmake-utils_src_configure
}
