# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openal/openal-1.13.ebuild,v 1.1 2011/03/19 18:56:45 ssuominen Exp $

EAPI=3
inherit cmake-utils git

MY_P=${PN}-soft-${PV}

DESCRIPTION="A software implementation of the OpenAL 3D audio API"
HOMEPAGE="http://kcat.strangesoft.net/openal.html"
SRC_URI=""
EGIT_REPO_URI="git://repo.or.cz/openal-soft.git"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="alsa debug oss portaudio pulseaudio"

RDEPEND="alsa? ( media-libs/alsa-lib )
	portaudio? ( >=media-libs/portaudio-19_pre )
	pulseaudio? ( media-sound/pulseaudio )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

DOCS="alsoftrc.sample"

src_unpack() {
	git_src_unpack
}

src_configure() {
	mycmakeargs=(
		$(cmake-utils_use alsa ALSA)
		$(cmake-utils_use oss OSS)
		$(cmake-utils_use portaudio PORTAUDIO)
		$(cmake-utils_use pulseaudio PULSEAUDIO)
		)

	cmake-utils_src_configure
}
