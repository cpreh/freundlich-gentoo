# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

RESTRICT="mirror"

inherit autotools eutils

MY_P=CEGUI-"${PV}"

DESCRIPTION="Crazy Eddie's GUI System"
HOMEPAGE="http://www.cegui.org.uk/"
SRC_URI="
	mirror://sourceforge/crayzedsgui/${MY_P}.tar.gz
	doc? ( mirror://sourceforge/crayzedsgui/CEGUI-DOCS-${PV}.tar.gz )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+X debug devil directfb doc examples expat irrlicht gtk lua minizip
+opengl python static-libs +stb +tga tiny-xml xerces-c xml"

RDEPEND="
	X? ( x11-libs/libX11 )
	dev-libs/libpcre
	media-libs/freetype:2
	devil? ( media-libs/devil )
	expat? ( dev-libs/exapt )
	gtk? ( x11-libs/gtk+:2 )
	irrlicht? ( dev-games/irrlicht )
	lua? (
		dev-lang/lua
		dev-lua/toluapp
	)
	opengl? (
		virtual/opengl
		media-libs/freeglut
		media-libs/glew
	)
	python? ( dev-libs/boost[python] )
	xerces-c? ( dev-libs/xerces-c )
	xml? ( dev-libs/libxml2 )
"
DEPEND="
	${RDEPEND}
	dev-util/pkgconfig
"

S="${WORKDIR}"/"${MY_P}"

src_prepare() {
	if use examples ; then
		cp -r Samples Samples.clean
		rm -f $(find Samples.clean -name 'Makefile*')
	fi

	eautoreconf
}

src_configure() {
	# dev-games/ogre depends on cegui
	# the external tinyxml library doesn't work with cegui
	econf \
		$(use_enable debug) \
		$(use_enable devil) \
		$(use_enable directfb directfb-renderer) \
		$(use_enable examples samples) \
		$(use_enable expat) \
		$(use_enable irrlicht irrlicht-renderer) \
		$(use_enable lua external-toluapp) \
		$(use_enable lua lua-module) \
		$(use_enable lua toluacegui) \
		$(use_enable minizip minizip-resource-provider) \
		$(use_enable opengl external-glew) \
		$(use_enable opengl opengl-renderer) \
		$(use_enable static-libs static) \
		$(use_enable stb) \
		$(use_enable tiny-xml tinyxml) \
		$(use_enable xerces-c) \
		$(use_enable xml libxml) \
		$(use_with X x) \
		$(use_with gtk gtk2) \
		--disable-corona \
		--disable-dependency-tracking \
		--disable-external-tinyxml \
		--disable-freeimage \
		--disable-ogre-renderer \
		--disable-silly
}

src_compile() {
	local ARGS="all"

	use doc && ARGS+=" doc"

	emake $ARGS || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	#remove .la files
	rm -f $(find ${D}/usr/$(get_libdir)/${P} -name *.la)

	#rename binarys
	find ${D}/usr/bin -type f -print0 | xargs -0 -I \{\} mv \{\} \{\}-${PV}

	#move and rename pkgconfig files
	mv "${D}/usr/$(get_libdir)/${P}/pkgconfig" "${D}/usr/$(get_libdir)"
	cd "${D}/usr/$(get_libdir)/pkgconfig"
	find -type f -print0 | xargs -0 -I \{\} basename \{\} .pc | \
		xargs -I \{\} mv \{\}.pc \{\}-${PV}.pc
	cd ${S}

	if use doc ; then
		dohtml -r doc/doxygen/html/* || die "dohtml failed"
	fi

	if use examples ; then
		insinto /usr/share/doc/${PF}/Samples
		doins -r Samples.clean/* || die "doins failed"
	fi
}
