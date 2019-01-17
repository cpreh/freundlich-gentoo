# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CMAKE_MIN_VERSION="3.1"
inherit cmake-utils

LIBNBTPP_VERSION="92f8d57227feb94643378ecf595626c60c0f59b8"
LIBNBTPP_DISTFILE="libnbtplusplus-${LIBNBTPP_VERSION}.tar.gz"
QUAZIP_VERSION="469b97b618314ec009a37cad22e9d2541d6481f7"
QUAZIP_DISTFILE="multimc-quazip-${QUAZIP_VERSION}.tar.gz"

DESCRIPTION="A custom launcher for Minecraft that allows you to easily manage multiple installations of Minecraft at once"
HOMEPAGE="https://multimc.org/"
SRC_URI="
	https://github.com/MultiMC/${PN}5/archive/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/MultiMC/libnbtplusplus/archive/${LIBNBTPP_VERSION}.tar.gz -> ${LIBNBTPP_DISTFILE}
	https://github.com/MultiMC/quazip/archive/${QUAZIP_VERSION}.tar.gz -> ${QUAZIP_DISTFILE}
"

# TODO: Check if this is still accurate.
LICENSE="Apache-2.0 GPL-2-with-classpath-exception GPL-2+ LGPL-3+ LGPL-2+ LGPL-2.1+ public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${PN}5-${PV}"

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtconcurrent:5
	dev-qt/qtnetwork:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	sys-libs/zlib
	>=virtual/jdk-1.6
	"

DEPEND="
	dev-qt/qttest:5
	dev-qt/qtchooser
	${RDEPEND}
"

src_configure() {
	local mycmakeargs=(
		-D MultiMC_LAYOUT=lin-system
	)

	cmake-utils_src_configure
}

src_unpack() {
	default

	rmdir "${S}/libraries/libnbtplusplus"
	mv "${WORKDIR}/libnbtplusplus-${LIBNBTPP_VERSION}" "${S}/libraries/libnbtplusplus"

	rmdir "${S}/libraries/quazip"
	mv "${WORKDIR}/quazip-${QUAZIP_VERSION}" "${S}/libraries/quazip"
}
