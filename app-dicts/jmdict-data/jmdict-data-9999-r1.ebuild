# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

DESCRIPTION="XML data for jmdict"
HOMEPAGE="http://jmdict.sourceforge.net/"
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-arch/gzip
        >=app-dicts/jmdict-0.6
        net-misc/wget
		sys-apps/coreutils"
RDEPEND=""

src_unpack() {
	wget -t 1 ftp://ftp.monash.edu.au/pub/nihongo/JMdict.gz || die "wget failed"
	mkdir "${S}" || die "mkdir ${S} failed"
	zcat JMdict.gz > "${S}"/JMdict || die "zcat failed"
}

src_compile() {
	mkdir -p "${S}"/usr/share/jmdict || die "mkdir failed"
	jmdict_import "${S}"/JMdict "${S}" || die "jmdict_import failed"
}

src_install() {
	cp -r usr "${D}"
}
