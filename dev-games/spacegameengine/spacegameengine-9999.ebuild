# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

CMAKE_MIN_VERSION="2.8.12"
inherit cmake-utils games git-2

EGIT_REPO_URI="git://github.com/freundlich/spacegameengine.git"

DESCRIPTION="An easy to use game engine written in C++"
HOMEPAGE="http://freundlich.github.com/spacegameengine/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+audio audio_null +camera cegui +cg +charconv +config +console
+consolegfx doc examples evdev +font +fontbitmap +fontdraw graph +image
+image2d +image3d +imagecolor +imageds +imageds2d +input +line_drawer +log
+media modelmd3 modelobj +openal opencl +opengl +pango +parse +parseini
+parsejson +plugin +png postprocessing projectile +renderer +rendereropengl
resource_tree rucksack scenic +shader +sprite static-libs +systems test
+texture +timer +viewport +vorbis +wave +window +x11input"

RDEPEND="
	~dev-cpp/fcppt-9999
	>=dev-libs/boost-1.47.0
	cegui? (
		>=dev-games/cegui-0.8.0
	)
	cg? (
		>=media-gfx/nvidia-cg-toolkit-3
	)
	charconv? (
		virtual/libiconv
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
	pango? (
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
		opengl? (
			media-libs/glew
			x11-libs/libX11
			x11-libs/libXrandr
		)
	)
	sprite? (
		~dev-cpp/majutsu-9999
	)
	vorbis? (
		media-libs/libvorbis
	)
	window? (
		~dev-cpp/libawl-9999
	)
	x11input? (
		x11-libs/libXi
		x11-libs/libX11
	)
"
#for doxygen formulas, 'latex', 'dvips' and 'gs' are needed
DEPEND="
	${RDEPEND}
	doc? (
		>=app-doc/doxygen-1.7.5
		app-text/dvipsk
		app-text/ghostscript-gpl
		dev-texlive/texlive-latex
	)
"

REQUIRED_USE="
	audio? ( log media plugin )
	audio_null? ( audio plugin )
	camera? ( input log parsejson renderer viewport )
	cegui? ( charconv imagecolor image2d input log renderer viewport )
	console? ( font )
	consolegfx? ( console font fontdraw imagecolor input renderer sprite )
	evdev? ( input log plugin window )
	font? ( log plugin )
	fontbitmap? ( font imagecolor image2d log parsejson )
	fontdraw? ( font imagecolor image2d renderer sprite texture )
	graph? ( image image2d imagecolor renderer sprite texture )
	image2d? ( image imagecolor media plugin )
	image3d? ( image imagecolor )
	imagecolor? ( image )
	imageds? ( image )
	imageds2d? ( image imageds )
	input? ( log plugin )
	line_drawer? ( imagecolor renderer )
	modelmd3? ( log )
	modelobj? ( charconv imagecolor log renderer )
	openal? ( audio log plugin )
	opencl? ( image2d imagecolor log renderer rendereropengl )
	opengl? ( image2d image3d imagecolor imageds imageds2d plugin renderer rendereropengl )
	pango? ( charconv font image2d imagecolor plugin )
	parseini? ( parse )
	parsejson? ( parse )
	plugin? ( log )
	png? ( image image2d imagecolor log plugin )
	postprocessing? ( cg config renderer shader viewport )
	projectile? ( imagecolor line_drawer log renderer )
	renderer? ( image2d image3d imagecolor imageds imageds2d log plugin )
	rucksack? ( viewport )
	scenic? ( camera cg charconv config imagecolor line_drawer modelobj parsejson renderer shader viewport )
	shader? ( cg renderer )
	sprite? ( renderer )
	systems? ( audio charconv config font image2d input log parseini plugin renderer sprite viewport window )
	texture? ( image2d log renderer )
	viewport? ( renderer window )
	vorbis? ( audio log plugin )
	wave? ( audio log plugin )
	x11input? ( input plugin window )
"

src_configure() {
	# Libs and includes go to the normal destination (/usr)
	# Everything else should go into the games dir (examples and media)
	local mycmakeargs=(
		-D INSTALL_DATA_DIR_BASE="${GAMES_DATADIR}"
		-D INSTALL_BINARY_DIR="${GAMES_BINDIR}"
		-D INSTALL_PLUGIN_DIR_BASE=$(games_get_libdir)
		-D INSTALL_DOC_DIR_BASE="/usr/share/doc"
		-D CHARCONV_BACKEND="iconv"
		$(cmake-utils_use_enable audio)
		$(cmake-utils_use_enable audio_null)
		$(cmake-utils_use_enable camera)
		$(cmake-utils_use_enable cegui)
		$(cmake-utils_use_enable cg)
		$(cmake-utils_use_enable charconv)
		$(cmake-utils_use_enable config)
		$(cmake-utils_use_enable console)
		$(cmake-utils_use_enable consolegfx)
		$(cmake-utils_use_enable doc)
		$(cmake-utils_use_enable examples)
		$(cmake-utils_use examples INSTALL_EXAMPLES)
		$(cmake-utils_use_enable evdev)
		$(cmake-utils_use_enable font)
		$(cmake-utils_use_enable fontbitmap)
		$(cmake-utils_use_enable fontdraw)
		$(cmake-utils_use_enable graph)
		$(cmake-utils_use_enable image)
		$(cmake-utils_use_enable image2d)
		$(cmake-utils_use_enable image3d)
		$(cmake-utils_use_enable imagecolor)
		$(cmake-utils_use_enable imageds)
		$(cmake-utils_use_enable imageds2d)
		$(cmake-utils_use_enable input)
		$(cmake-utils_use_enable line_drawer)
		$(cmake-utils_use_enable log)
		$(cmake-utils_use_enable media)
		$(cmake-utils_use_enable modelmd3)
		$(cmake-utils_use_enable modelobj)
		$(cmake-utils_use_enable openal)
		$(cmake-utils_use_enable opencl)
		$(cmake-utils_use_enable opengl)
		$(cmake-utils_use_enable pango)
		$(cmake-utils_use_enable parse)
		$(cmake-utils_use_enable parseini)
		$(cmake-utils_use_enable parsejson)
		$(cmake-utils_use_enable plugin)
		$(cmake-utils_use_enable png)
		$(cmake-utils_use_enable postprocessing)
		$(cmake-utils_use_enable projectile)
		$(cmake-utils_use_enable renderer)
		$(cmake-utils_use_enable rendereropengl)
		$(cmake-utils_use_enable resource_tree)
		$(cmake-utils_use_enable rucksack)
		$(cmake-utils_use_enable scenic)
		$(cmake-utils_use_enable shader)
		$(cmake-utils_use_enable sprite)
		$(cmake-utils_use_enable static-libs STATIC)
		$(cmake-utils_use_enable systems)
		$(cmake-utils_use_enable test)
		$(cmake-utils_use_enable texture)
		$(cmake-utils_use_enable timer)
		$(cmake-utils_use_enable viewport)
		$(cmake-utils_use_enable vorbis)
		$(cmake-utils_use_enable window)
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

	# Remove empty directories because doxygen creates them
	find "${D}" -type d -empty -delete || die

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
}

pkg_postinst() {
	games_pkg_postinst
}
