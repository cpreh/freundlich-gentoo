# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils git

EGIT_REPO_URI="git://timeout.supraverse.net/spacegameengine.git"

DESCRIPTION="An easy to use game engine written in C++"
HOMEPAGE="http://redmine.supraverse.net/projects/show/sge"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="
audio_null +bullet +camera +config +console +devil
examples +fontbitmap +fonttext +gui +iconv md3
+openal +opengl +parse +png +shader +sprite +systems
test +texture +time +truetype +vorbis +wave +x11input"

DEPEND="
	=dev-cpp/fcppt-scm
	=dev-cpp/mizuiro-scm[fcppt]
	=dev-cpp/libawl-scm
	>=dev-libs/boost-1.44.0
	x11-libs/libX11
	bullet? (
		sci-physics/bullet
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
	truetype? (
		media-libs/freetype
	)
	vorbis? (
		media-libs/libvorbis
	)
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs="	
		$(cmake-utils_use_enable audio_null)
		$(cmake-utils_use_enable bullet)
		$(cmake-utils_use_enable camera)
		$(cmake-utils_use_enable config)
		$(cmake-utils_use_enable console)
		$(cmake-utils_use_enable devil)
		$(cmake-utils_use_enable examples)
		$(cmake-utils_use_enable fontbitmap)
		$(cmake-utils_use_enable fonttext)
		$(cmake-utils_use_enable gui)
		$(cmake-utils_use_enable iconv)
		$(cmake-utils_use_enable md3)
		$(cmake-utils_use_enable openal)
		$(cmake-utils_use_enable opengl)
		$(cmake-utils_use_enable parse)
		$(cmake-utils_use_enable png)
		$(cmake-utils_use_enable shader)
		$(cmake-utils_use_enable sprite)
		$(cmake-utils_use_enable systems)
		$(cmake-utils_use_enable test)
		$(cmake-utils_use_enable texture)
		$(cmake-utils_use_enable time)
		$(cmake-utils_use_enable truetype)
		$(cmake-utils_use_enable vorbis)
		$(cmake-utils_use_enable wave)
		$(cmake-utils_use_enable x11input)
		-D BULLET_INCLUDE_DIR=/usr/include/bullet
	"

	cmake-utils_src_configure
}
