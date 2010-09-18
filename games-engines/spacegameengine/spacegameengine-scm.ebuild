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
IUSE="+bullet +devil examples +gui md3 +openal +opengl +png test +truetype +vorbis +wave +x11input"

DEPEND="
	=dev-cpp/fcppt-scm
	=dev-cpp/mizuiro-scm[fcppt]
	>=dev-libs/boost-1.43.0
	x11-libs/libX11
	bullet? (
		sci-physics/bullet
	)
	devil? (
		media-libs/devil
	)
	openal? (
		media-libs/openal
	)
	opengl? (
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
		-D ENABLE_AUDIO_NULL=OFF
		-D ENABLE_BITMAP_FONT=OFF
		-D ENABLE_ODE=OFF
		$(cmake-utils_use_enable bullet)
		$(cmake-utils_use_enable devil)
		$(cmake-utils_use_enable examples)
		$(cmake-utils_use_enable gui)
		$(cmake-utils_use_enable md3)
		$(cmake-utils_use_enable openal)
		$(cmake-utils_use_enable opengl)
		$(cmake-utils_use_enable png)
		$(cmake-utils_use_enable test)
		$(cmake-utils_use_enable truetype)
		$(cmake-utils_use_enable vorbis)
		$(cmake-utils_use_enable x11input)
	"

	cmake-utils_src_configure
}
