# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="XML data for jmdict"
HOMEPAGE="http://mandrill.fuxx0r.net/jmdict.php"
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-arch/gzip
        >=app-dicts/jmdict-0.6
        net-misc/wget"
RDEPEND=""

src_unpack() {
	cd "${WORKDIR}"
	wget -t 1 ftp://ftp.monash.edu.au/pub/nihongo/JMdict.gz || die "wget failed"
	gzip -d JMdict.gz || die "gzip -d failed"
}

src_compile() {
	mkdir -p "${S}"/usr/share/jmdict || die "mkdir failed"
	jmdict_import "${WORKDIR}"/JMdict "${S}" || die "jmdict_import failed"
}

src_install() {
	cp -R usr "${D}"
}
