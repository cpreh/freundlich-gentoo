# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git

DESCRIPTION="OpenAL Soft is a cross-platform software implementation of the OpenAL 3D audio API."
HOMEPAGE="http://kcat.strangesoft.net/openal.html"

EGIT_REPO_URI="git://repo.or.cz/openal-soft.git"

EAPI="2"
LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa alsoftconfig examples oss portaudio pulseaudio"

DEPEND="${RDEPEND}
        >=dev-util/cmake-2.4
		dev-util/git"
RDEPEND="alsa? ( media-libs/alsa-lib )
         portaudio? ( media-libs/portaudio )
         pulseaudio? ( media-sound/puselaudio )"

src_configure() {
	local myconf=""

	use alsa || myconf="${myconf} -DALSA:=off"
	use alsoftconfig && myconf="${myconf} -DALSOFT_CONFIG:=on"
	use examples || myconf="${myconf} -DEXAMPLES:=off"
	use oss || myconf="${myconf} -DOSS:=off"
	use portaudio || myconf="${myconf} -DPORTAUDIO:=off"
	use pulseaudio || myconf="${myconf} -DPULSEAUDIO:=off"

	mkdir -p CMakeConf
	cd CMakeConf
	cmake ${myconf} \
		-DSOLARIS:=off \
		-DDSOUND:=off \
		-DWINMM:=off \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		-DCMAKE_INSTALL_PREFIX=/usr \
		.. || die "cmake failed"
}

src_compile() {
	cd CMakeConf
	emake || die "emake failed"
}

src_install() {
	cd CMakeConf
	emake DESTDIR=${D} install || die "emake install failed"
}
