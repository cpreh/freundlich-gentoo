# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
RESTRICT="mirror"

inherit versionator

MY_PV="$(get_version_component_range 1-2)"
MY_DATE="February2012"

DESCRIPTION="NVIDIA's C graphics compiler toolkit"
HOMEPAGE="http://developer.nvidia.com/object/cg_toolkit.html"
SRC_URI="x86? ( http://developer.download.nvidia.com/cg/Cg_${MY_PV}/Cg-${MY_PV}_${MY_DATE}_x86.tgz )
	amd64? ( http://developer.download.nvidia.com/cg/Cg_${MY_PV}/Cg-${MY_PV}_${MY_DATE}_x86_64.tgz )"

LICENSE="NVIDIA"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RESTRICT="strip"

RDEPEND="media-libs/freeglut"

DEST="/opt/${PN}"

S="${WORKDIR}"

src_install() {
	into ${DEST}
	dobin usr/bin/cgc
	dosym ${DEST}/bin/cgc /opt/bin/cgc

	exeinto ${DEST}/lib
	if use x86 ; then
		doexe usr/lib/*
	elif use amd64 ; then
		doexe usr/lib64/*
	fi

	doenvd "${FILESDIR}"/80cgc-opt

	insinto ${DEST}/include/Cg
	doins usr/include/Cg/*

	dosym ${DEST}/include/Cg /usr/include/Cg
	dosym ${DEST}/lib/libCg.so /usr/lib/libCg.so
	dosym ${DEST}/lib/libCgGL.so /usr/lib/libCgGL.so

	insinto ${DEST}
	doins -r usr/local/Cg/{docs,examples,README}
}

pkg_postinst() {
	einfo "Starting with ${CATEGORY}/${PN}-2.1.0016, ${PN} is installed in"
	einfo "${DEST}.  Packages might have to add something like:"
	einfo "  append-cppflags -I ${DEST}/include"
	ebeep
}
