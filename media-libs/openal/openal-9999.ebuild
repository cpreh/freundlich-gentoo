# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git

DESCRIPTION="OpenAL Soft is a cross-platform software implementation of the OpenAL 3D audio API."
HOMEPAGE="http://kcat.strangesoft.net/openal.html"

EGIT_REPO_URI="git://repo.or.cz/openal-soft.git"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa examples oss"

DEPEND="${RDEPEND}
        >=dev-util/cmake-2.4
		dev-util/git"
RDEPEND="alsa? ( media-libs/alsa-lib )"

src_unpack() {
	git_src_unpack
	cd ${S}
}

src_compile() {
	local myconf=""

	use alsa || myconf="${myconf} -DALSA:=off"
	use examples || myconf="${myconf} -DEXAMPLES:=off"
	use oss || myconf="${myconf} -DOSS:=off"

	cd CMakeConf
	cmake ${myconf} \
		-DOSS:=off \
		-DSOLARIS:=off \
		-DDSOUND:=off \
		-DWINMM:=off \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		-DCMAKE_INSTALL_PREFIX=/usr \
		.. || die "cmake failed"
	emake || die "emake failed"
}

src_install() {
	cd CMakeConf
	emake DESTDIR=${D} install || die "emake install failed"
}
