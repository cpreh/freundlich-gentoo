# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/apitrace/apitrace-3.0-r1.ebuild,v 1.4 2013/03/02 20:19:29 hwoarang Exp $

EAPI="4"
PYTHON_DEPEND="2:2.6"

inherit cmake-utils eutils python multilib vcs-snapshot

DESCRIPTION="A tool for tracing, analyzing, and debugging graphics APIs"
HOMEPAGE="https://github.com/apitrace/apitrace"
SRC_URI="https://github.com/${PN}/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="egl multilib qt4"

RDEPEND="app-arch/snappy
	media-libs/libpng
	sys-libs/zlib
	media-libs/mesa[egl?]
	egl? ( || (
		>=media-libs/mesa-8.0[gles1,gles2]
		<media-libs/mesa-8.0[gles]
	) )
	x11-libs/libX11
	multilib? ( app-emulation/emul-linux-x86-baselibs )
	qt4? (
		>=dev-qt/qtcore-4.7:4
		>=dev-qt/qtgui-4.7:4
		>=dev-qt/qtwebkit-4.7:4
		>=dev-libs/qjson-0.5
	)"
DEPEND="${RDEPEND}"

EMULTILIB_PKG="true"

PATCHES=(
	"${FILESDIR}"/${P}-system-libs.patch
	"${FILESDIR}"/${P}-glxtrace-only.patch
	"${FILESDIR}"/${PN}-3.0-gcc47.patch
	"${FILESDIR}"/${P}-libpng16.patch
)

pkg_setup() {
	python_set_active_version 2
}

src_prepare() {
	base_src_prepare

	# Workaround NULL DT_RPATH issues
	sed -i -e "s/install (TARGETS/#\0/" gui/CMakeLists.txt || die
}

src_configure() {
	for ABI in $(get_install_abis) ; do
		mycmakeargs=(
			$(cmake-utils_use_enable qt4 GUI)
			$(cmake-utils_use_enable egl EGL)
		)

		if use multilib ; then
			if [[ "${ABI}" != "${DEFAULT_ABI}" ]] ; then
				mycmakeargs=(
					-DBUILD_LIB_ONLY=ON
					-DENABLE_GUI=OFF
					$(cmake-utils_use_enable egl EGL)
				)
			fi
			multilib_toolchain_setup ${ABI}
		fi

		CMAKE_BUILD_DIR="${WORKDIR}/${P}_build-${ABI}"
		cmake-utils_src_configure
	done
}

src_compile() {
	for ABI in $(get_install_abis) ; do
		use multilib && multilib_toolchain_setup ${ABI}
		CMAKE_BUILD_DIR="${WORKDIR}/${P}_build-${ABI}"
		cmake-utils_src_compile
	done
}

src_install() {
	dobin "${CMAKE_BUILD_DIR}"/{glretrace,apitrace}
	use qt4 && dobin "${CMAKE_BUILD_DIR}"/qapitrace

	for ABI in $(get_install_abis) ; do
		CMAKE_BUILD_DIR="${WORKDIR}/${P}_build-${ABI}"
		exeinto /usr/$(get_libdir)/${PN}/wrappers
		doexe "${CMAKE_BUILD_DIR}"/wrappers/*.so
		dosym glxtrace.so /usr/$(get_libdir)/${PN}/wrappers/libGL.so
		dosym glxtrace.so /usr/$(get_libdir)/${PN}/wrappers/libGL.so.1
		dosym glxtrace.so /usr/$(get_libdir)/${PN}/wrappers/libGL.so.1.2
	done

	dodoc {BUGS,DEVELOPMENT,NEWS,README,TODO}.markdown

	exeinto /usr/$(get_libdir)/${PN}/scripts
	doexe $(find scripts -type f -executable)
}