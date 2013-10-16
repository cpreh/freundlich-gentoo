# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/nvidia-cg-toolkit/nvidia-cg-toolkit-3.1.0013-r2.ebuild,v 1.2 2013/05/12 07:19:17 patrick Exp $

EAPI=5

inherit multilib prefix versionator multilib-minimal

MY_PV="$(get_version_component_range 1-2)"
MY_DATE="April2012"

DESCRIPTION="NVIDIA's C graphics compiler toolkit"
HOMEPAGE="http://developer.nvidia.com/object/cg_toolkit.html"
MY_URI="http://developer.download.nvidia.com/cg/Cg_${MY_PV}/Cg-${MY_PV}_${MY_DATE}_x86_64.tgz"
SRC_URI="
	abi_x86_64? ( ${MY_URI} -> ${P}.x86_64.tgz )
	abi_x86_32? ( ${MY_URI/x86_64/x86} -> ${P}.i386.tgz )
"

LICENSE="NVIDIA-r1"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="doc examples"

RESTRICT="strip"

NATIVE_DEPS="
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXt
	media-libs/glu
	media-libs/mesa
"

RDEPEND="
	media-libs/freeglut

	abi_x86_64? ( ${NATIVE_DEPS} )
	abi_x86_32? ( 
		amd64? ( 
			|| (
				(
					x11-libs/libICE[abi_x86_32(-)]
					x11-libs/libSM[abi_x86_32(-)]
					x11-libs/libX11[abi_x86_32(-)]
					x11-libs/libXext[abi_x86_32(-)]
					x11-libs/libXi[abi_x86_32(-)]
					x11-libs/libXmu[abi_x86_32(-)]
					x11-libs/libXt[abi_x86_32(-)]
				)
				app-emulation/emul-linux-x86-xlibs[-abi_x86_32(-)]
			)
			|| (
				(
					media-libs/glu[abi_x86_32(-)]
					media-libs/mesa[abi_x86_32(-)]
				)
				app-emulation/emul-linux-x86-opengl[-abi_x86_32(-)]
			)
		) 		
		x86? ( 
			${NATIVE_DEPS}
			virtual/libstdc++:3.3
		)
	)
"
DEPEND=""

S=${WORKDIR}

DEST=/opt/${PN}

QA_PREBUILT="${DEST}/*"

src_unpack() {
	local files=( ${A} )

	multilib_src_unpack() {
		mkdir -p "${BUILD_DIR}" || die
		cd "${BUILD_DIR}" || die

		# we need to filter out the other archive(s)
		local other_abi
		[[ ${ABI} == amd64 ]] && other_abi=i386 || other_abi=x86_64
		unpack ${files[@]//*${other_abi}*/}
	}
	multilib_parallel_foreach_abi multilib_src_unpack
}

install_pkgconfig() {
	# Two args: .pc file + abi
	local suffix
	use abi_x86_64 && use abi_x86_32 && [[ $2 == x86 ]] && suffix="-32"
	insinto /usr/$(get_abi_LIBDIR ${DEFAULT_ABI})/pkgconfig
	sed \
		-e "s:GENTOO_LIBDIR:$(ABI=$2 get_libdir):g" \
		-e "s:DESCRIPTION:${DESCRIPTION}:g" \
		-e "s:VERSION:${PV}:g" \
		-e "s|HOMEPAGE|${HOMEPAGE}|g" \
		-e "s:SUFFIX:${suffix}:g" \
		"${FILESDIR}/${1}.in" > "${T}/${1/.pc/${suffix}.pc}" || die
		eprefixify "${T}/${1/.pc/${suffix}.pc}"
	doins "${T}/${1/.pc/${suffix}.pc}"
}

multilib_src_install() {

	if multilib_build_binaries; then
		into ${DEST}
		dobin usr/bin/{cgc,cgfxcat,cginfo}
	
		insinto ${DEST}/include
		doins -r usr/include/Cg

		insinto ${DEST}
		dodoc usr/local/Cg/README
		if use doc; then
			dodoc usr/local/Cg/docs/*.{txt,pdf}
			dohtml -r usr/local/Cg/docs/html/*
		fi
		if use examples; then
			insinto /usr/share/${PN}
			doins -r usr/local/Cg/examples
		fi
		find usr/local/Cg/{docs,examples,README} -delete
	fi
	
	into ${DEST}
	dolib usr/lib*/*

	install_pkgconfig nvidia-cg-toolkit.pc "${ABI}"
	install_pkgconfig nvidia-cg-toolkit-gl.pc "${ABI}"
}

multilib_src_install_all() {
	local ldpath
	ldpath="${EPREFIX}${DEST}/$(get_libdir)"
	use abi_x86_64 && use abi_x86_32 && ldpath+=":${EPREFIX}${DEST}/lib32"
	sed \
		-e "s|ELDPATH|${ldpath}|g" \
		"${FILESDIR}"/80cgc-opt-2 > "${T}"/80cgc-opt || die
	eprefixify "${T}"/80cgc-opt
	doenvd "${T}"/80cgc-opt
}

pkg_postinst() {
	if [[ ${REPLACING_VERSIONS} < 2.1.0016 ]]; then
		einfo "Starting with ${CATEGORY}/${PN}-2.1.0016, ${PN} is installed in"
		einfo "${DEST}. Packages might have to add something like:"
		einfo "  append-cppflags -I${DEST}/include"
	fi
}
