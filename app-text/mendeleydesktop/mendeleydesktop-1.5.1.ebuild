# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# http://bugs.gentoo.org/show_bug.cgi?id=308509

EAPI=4

inherit eutils

DESCRIPTION="A free research management tool for desktop & web"
HOMEPAGE="http://www.mendeley.com/"

# Version 1.0.1 downloaded from mendeley.com is NOT version 1.0.1 but version 1.0!
# SRC_URI="${HOMEPAGE}/downloads/linux/${P}-${LNXARCH}.tar.bz2"
SRC_URI_BASE="http://download.mendeley.com/linux/${P}-"
SRC_URI_x86="${SRC_URI_BASE}linux-i486.tar.bz2 -> ${P}-linux-i486.tar.bz2"
SRC_URI_amd64="${SRC_URI_BASE}linux-x86_64.tar.bz2 -> ${P}-linux-x86_64.tar.bz2"
SRC_URI="x86? ( ${SRC_URI_x86} )
	amd64? ( ${SRC_URI_amd64} )"

LICENSE="Mendelay-EULA"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""
RESTRICT="primaryuri mirror strip"
# This used to have a dependency on dev-libs/openssl:0.9.8, but apparently that
# isn't necessary
RDEPEND="media-libs/libpng:1.2"

S="${WORKDIR}/mendeley_unpacked"

MENDELEY_INSTALL_DIR="/opt/${PN}"

src_unpack() {
	unpack "${A}"
	# Ok, this is sort of a hack. mendeley comes in two versions which
	# create two different directories when unpacked. However, the archive(s)
	# should contain exactly _one_ directory.
	# We make sure of that first by finding all direct subdirectories of
	# $WORKDIR and counting them. find outputs the $WORKDIR first, so there's a
	# '2' instead of a '1'
	if [ ! $(find ${WORKDIR} -maxdepth 1 -type d | wc -l) -eq 2 ]; then
		eerror "The working directory contained more than one file after "
		eerror "extracting the tarball. That's not possible."
		die "Integrity violation"
	fi
	# Then, we rename the one directory to the value $S
	mv ${WORKDIR}/* ${WORKDIR}/mendeley_unpacked
}

src_install() {
	# install menu
	domenu "share/applications/${PN}.desktop"
	# Install commonly used icon sizes
	for res in 16x16 22x22 32x32 48x48 64x64 128x128 ; do
		insinto "/usr/share/icons/hicolor/${res}/apps"
		doins "share/icons/hicolor/${res}/apps/${PN}.png"
	done
	insinto "/usr/share/pixmaps"
	doins "share/icons/hicolor/48x48/apps/${PN}.png"

	# dodoc
	dodoc "share/doc/${PN}/"*

	# create directories for installation
	dodir ${MENDELEY_INSTALL_DIR}
	dodir "${MENDELEY_INSTALL_DIR}/lib"
	dodir "${MENDELEY_INSTALL_DIR}/share"

	# install binaries
	mv "bin" "${D}${MENDELEY_INSTALL_DIR}"
	mv "lib" "${D}${MENDELEY_INSTALL_DIR}"
	mv "share/${PN}" "${D}${MENDELEY_INSTALL_DIR}/share"
	# We have to create /opt explicitly or we get a warning. dodir seems like
	# the right thing to do (since app-text/acroread does it, too)
	#   - pimiddy
	dodir /opt/bin || die "Creating directory failed."
	dosym "${MENDELEY_INSTALL_DIR}/bin/${PN}" "/opt/bin/${PN}"
}

