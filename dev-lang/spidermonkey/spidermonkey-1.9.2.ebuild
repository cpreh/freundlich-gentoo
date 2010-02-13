# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

RESTRICT="mirror"

MAINVERSION="1.9.2"
SNAPSHOTVERSION="672df9e9c441"
PACKAGENAME=spidermonkey-"${MAINVERSION}"-"${SNAPSHOTVERSION}"

DESCRIPTION="SpiderMonkey is the code-name for the Mozilla's C implementation of JavaScript."
HOMEPAGE="http://www.mozilla.org/js/spidermonkey/"
SRC_URI="http://flusspferd.org/downloads/${PACKAGENAME}.tar.bz2"

LICENSE="NPL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="threadsafe"

RDEPEND="dev-libs/nspr"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/"${PACKAGENAME}"/src

src_configure() {
	cd "${S}"

	econf \
		$(use_enable threadsafe) \
		--with-system-nspr \
		|| die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
