# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

CMAKE_MIN_VERSION="3.1"
inherit cmake-utils git-r3

DESCRIPTION="A custom launcher for Minecraft that allows you to easily manage multiple installations of Minecraft at once"
HOMEPAGE="https://multimc.org/"
EGIT_REPO_URI="https://github.com/MultiMC/MultiMC5"

LICENSE="Apache-2.0 GPL-2-with-classpath-exception GPL-2+ LGPL-3+ LGPL-2+ LGPL-2.1+ public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtnetwork:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	sys-libs/zlib
	>=virtual/jdk-1.6
	"

DEPEND="
	dev-qt/qtconcurrent:5
	dev-qt/qttest:5
	dev-qt/qtchooser
	${RDEPEND}
	"

src_configure() {
	local mycmakeargs=(
		-D CMAKE_BUILD_WITH_INSTALL_RPATH=ON
	)

	cmake-utils_src_configure
}

src_install() {
	newbin "${BUILD_DIR}"/MultiMC MultiMC_impl
	dobin "${FILESDIR}"/MultiMC
	dolib "${BUILD_DIR}"/libMultiMC_{gui,logic,nbt++,rainbow}.so
	insinto /usr/bin/jars
	doins "${BUILD_DIR}"/jars/{JavaCheck.jar,NewLaunch.jar}
}
