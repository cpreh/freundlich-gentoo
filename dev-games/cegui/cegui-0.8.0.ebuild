# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_DEPEND="2"

inherit cmake-utils python

DESCRIPTION="Crazy Eddie's GUI System"
HOMEPAGE="http://www.cegui.org.uk/"
SRC_URI="mirror://sourceforge/crayzedsgui/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="
	bidi devil directfb examples expat freeimage gtk irrlicht lua minizip ogre
	opengl pcre python static-libs tinyxml truetype xerces-c xml"

RDEPEND="
	bidi? ( dev-libs/fribidi )
	devil? ( media-libs/devil )
	directfb? ( dev-libs/DirectFB )
	examples? (
		gtk? ( x11-libs/gtk+:2 )
		ogre? ( dev-games/ogre[ois] )
		opengl? ( media-libs/glfw )
	)
	expat? ( dev-libs/expat )
	freeimage? ( media-libs/freeimage )
	irrlicht? ( dev-games/irrlicht )
	lua? (
		dev-lang/lua
		dev-lua/toluapp
	)
	minizip? ( sys-libs/zlib[minizip] )
	opengl? (
		virtual/opengl
		virtual/glu
		media-libs/glew
		media-libs/glm
	)
	ogre? ( dev-games/ogre )
	pcre? ( dev-libs/libpcre )
	python? ( >=dev-libs/boost-1.48.0[python] )
	tinyxml? ( dev-libs/tinyxml )
	truetype? ( media-libs/freetype:2 )
	xerces-c? ( dev-libs/xerces-c )
	xml? ( dev-libs/libxml2 )
"

DEPEND="
	${RDEPEND}
"

pkg_setup() {
	if use python ; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_configure() {
	local mycmakeargs=(
		-D CEGUI_BUILD_EMBEDDED_GLEW=OFF
		-D CEGUI_BUILD_EMBEDDED_TOLUAPP=OFF
		-D CEGUI_BUILD_IMAGECODEC_STB=ON
		-D CEGUI_BUILD_IMAGECODEC_TGA=ON
		-D CEGUI_USE_MINIBIDI=OFF
		$(cmake-utils_use bidi CEGUI_USE_FRIBIDI)
		$(cmake-utils_use devil CEGUI_BUILD_IMAGECODEC_DEVIL)
		$(cmake-utils_use directfb CEGUI_BUILD_RENDERER_DIRECTFB)
		$(cmake-utils_use examples CEGUI_SAMPLES_ENABLED)
		$(cmake-utils_use expat CEGUI_BUILD_XMLPARSERS_EXPAT)
		$(cmake-utils_use freeimage CEGUI_BUILD_IMAGECODEC_FREEIMAGE)
		$(cmake-utils_use irrlicht CEGUI_BUILD_RENDERER_IRRLICHT)
		$(cmake-utils_use lua CEGUI_BUILD_LUA_GENERATOR)
		$(cmake-utils_use lua CEGUI_BUILD_LUA_MODULE)
		$(cmake-utils_use minizip CEGUI_HAS_MINIZIP_RESOURCE_PROVIDER)
		$(cmake-utils_use ogre CEGUI_BUILD_RENDERER_OGRE)
		$(cmake-utils_use opengl CEGUI_BUILD_RENDERER_OPENGL)
		$(cmake-utils_use pcre CEGUI_HAS_PCRE_REGEX)
		$(cmake-utils_use python CEGUI_BUILD_PYTHON_MODULES)
		$(cmake-utils_use static-libs CEGUI_BUILD_STATIC_CONFIGURATION)
		$(cmake-utils_use tinyxml CEGUI_BUILD_XMLPARSER_TINYXML)
		$(cmake-utils_use truetype CEGUI_HAS_FREETYPE)
		$(cmake-utils_use xerces-c CEGUI_BUILD_XMLPARSERS_XERCES)
		$(cmake-utils_use xml CEGUI_BUILD_XMLPARSERS_LIBXML2)
	)

	if use examples && use gtk; then
		mycmakeargs+="-D CEGUI_SAMPLES_USE_GTK2=ON"
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	cat > "${T}/env" << EOF
LDPATH=/usr/lib/cegui-0.8
EOF
	newenvd "${T}/env" 99cegui
}
