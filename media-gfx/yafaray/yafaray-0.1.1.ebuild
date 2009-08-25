# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit multilib

RESTRICT="mirror"

MY_PN="YafaRay"

DESCRIPTION="YafaRay is a raytracing open source render engine"
HOMEPAGE="http://www.yafaray.org/"
SRC_URI="http://static.yafaray.org/sources/${MY_PN}.${PV}.zip
	blender? (
	http://static.yafaray.org/sources/${MY_PN}-blender.${PV}.zip
	)"

EAPI="2"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="blender debug jpeg openexr png qt4 truetype xml zlib"

RDEPEND="
	blender? ( >=media-gfx/blender-2.49 )
	jpeg? ( media-libs/jpeg )
	openexr? ( media-libs/openexr )
	png? ( media-libs/libpng )
	qt4? ( x11-libs/qt-gui:4 x11-libs/qt-core:4 )
	truetype? ( media-libs/freetype )
	xml? ( dev-libs/libxml2 )
	zlib? ( sys-libs/zlib )"
DEPEND="
	app-arch/unzip
	dev-lang/swig
	>=dev-util/scons-0.97
	${RDEPEND}"

S="${WORKDIR}/${PN}"

src_prepare() {
	# add correct paths for qt-libs
	echo 'gui_env.Append(CPPPATH = ["/usr/include/qt4"])' >> "${S}"/src/gui/SConscript
	echo "gui_env.Append(LIBPATH = [\"/usr/$(get_libdir)/qt4\"])" >> "${S}"/src/gui/SConscript
}

src_configure() {
	cat > "${S}"/user-config.py << _EOF_

PREFIX = '${D}/usr'
CCFLAGS = '-Wall ${CXXFLAGS}'
REL_CCFLAGS = '-ffast-math'
DEBUG_CCFLAGS = '-ggdb'
YF_LIBOUT = '\${PREFIX}/$(get_libdir)'
YF_PLUGINPATH = '\${PREFIX}/lib/yafaray'
YF_BINPATH = '/\${PREFIX}/bin'

YF_DEBUG = '$(if use debug ; then echo true ; else echo false ; fi)'

BASE_LPATH = '\${PREFIX}/$(get_libdir)'
BASE_IPATH = '/usr/include'

### pthreads
YF_PTHREAD_LIB = 'pthread'

### OpenEXR
WITH_YF_EXR = '$(if use openexr ; then echo true ; else echo false ; fi)'
YF_EXR_INC = '\${BASE_IPATH}/OpenEXR'
YF_EXR_LIB = 'Half Iex Imath IlmImf'
YF_EXR_LIBPATH = '${BASE_LPATH}'

### libXML
WITH_YF_XML = '$(if use xml ; then echo true ; else echo false ; fi)'
YF_XML_INC = '\${BASE_IPATH}/libxml2'
YF_XML_LIB = 'xml2'

### JPEG
WITH_YF_JPEG = '$(if use jpeg ; then echo true ; else echo false ; fi)'
YF_JPEG_INC = ''
YF_JPEG_LIB = 'jpeg'

### PNG
WITH_YF_PNG = '$(if use png ; then echo true ; else echo false ; fi)'
YF_PNG_INC = ''
YF_PNG_LIB = 'png'

### zlib
WITH_YF_ZLIB = '$(if use zlib ; then echo true ; else echo false ; fi)'
YF_ZLIB_INC = ''
YF_ZLIB_LIB = 'z'

### Freetype 2
WITH_YF_FREETYPE = '$(if use truetype ; then echo true ; else echo false ; fi)'
YF_FREETYPE_INC = '\${BASE_IPATH}/freetype2'
YF_FREETYPE_LIB = 'freetype'

### Miscellaneous
YF_MISC_LIB = 'dl'

# qt
WITH_YF_QT = '$(if use qt4 ; then echo true ; else echo false ; fi)'
YF_QTDIR='/usr'

_EOF_
}

src_compile() {
	scons ${MAKEOPTS} || die "scons failed"
	scons swig || die "scons swig failed"
}

src_install() {
	scons ${MAKEOPTS} install || die "scons install failed"
	scons swig_install || die "scons swig_install failed"

	if use blender; then
		cd ../yafaray-blender
		insinto /usr/share/blender/scripts
		doins yafaray_ui.py
		insinto /usr/share/yafaray/blender
		doins yaf_*.py
	fi
}
