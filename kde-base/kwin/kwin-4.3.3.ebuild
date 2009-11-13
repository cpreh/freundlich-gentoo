# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"

KMNAME="kdebase-workspace"
OPENGL_REQUIRED="optional"
inherit kde4-meta

DESCRIPTION="KDE window manager"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~x86"
IUSE="debug xcomposite xinerama"

# NOTE disabled for now: captury? ( media-libs/libcaptury )
COMMONDEPEND="
	$(add_kdebase_dep kephal)
	$(add_kdebase_dep libkworkspace)
	x11-libs/libXdamage
	x11-libs/libXfixes
	>=x11-libs/libXrandr-1.2.1
	x11-libs/libXrender
	opengl? ( virtual/opengl )
	xcomposite? ( x11-libs/libXcomposite )
	xinerama? ( x11-libs/libXinerama )
"
DEPEND="${COMMONDEPEND}
	x11-proto/damageproto
	x11-proto/renderproto
	xcomposite? ( x11-proto/compositeproto )
	xinerama? ( x11-proto/xineramaproto )
"
RDEPEND="${COMMONDEPEND}"

PATCHES=(
	"${FILESDIR}/4.3.3-fix_no_opengl.patch"
)

src_prepare() {
# NOTE uncomment when enabled again by upstream
#	if ! use captury; then
#		sed -e 's:^PKGCONFIG..libcaptury:#DONOTFIND &:' \
#			-i kwin/effects/CMakeLists.txt || \
#			die "Making captury optional failed."
#	fi

	kde4-meta_src_prepare
}

src_configure() {
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_with opengl OpenGL)"

	kde4-meta_src_configure
}
