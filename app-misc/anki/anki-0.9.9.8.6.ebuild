# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/anki/anki-0.9.9.8.5.ebuild,v 1.1 2009/07/21 00:39:39 hncaldwell Exp $

EAPI=2

inherit eutils multilib python

RESTRICT="mirror"

DESCRIPTION="A spaced-repetition memory training program (flash cards)"
HOMEPAGE="http://ichi2.net/anki/"
SRC_URI="http://anki.googlecode.com/files/${P}.tgz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="furigana +graph latex recording +sound"

DEPEND="dev-lang/python
	dev-python/setuptools"
RDEPEND=">=dev-python/PyQt4-4.4[X,svg,webkit]
	>=dev-python/sqlalchemy-0.5.3
	>=dev-python/simplejson-1.7.3
	>=dev-python/beautifulsoup-3.1
	|| ( >=dev-python/pysqlite-2.3.0 >=dev-lang/python-2.5[sqlite] )
	latex? ( app-text/dvipng )
	furigana? ( app-i18n/kakasi )
	graph? (
		dev-python/numpy
		>=dev-python/matplotlib-0.91.2
	)
	recording? (
		media-sound/sox
		dev-python/pyaudio
		media-sound/lame
	)
	sound? ( media-video/mplayer )"

src_install() {
	doicon icons/${PN}.png || die

	cd libanki
	python setup.py install --root="${D}" || die
	cd ..
	python setup.py install --root="${D}" || die

	make_desktop_entry ${PN} ${PN} ${PN}.png "Education"
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/ankiqt
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/anki
}

pkg_postrm() {
	python_version
	python_mod_cleanup /usr/$(get_libdir)/python${PYVER}/site-packages/ankiqt
	python_mod_cleanup /usr/$(get_libdir)/python${PYVER}/site-packages/anki
}
