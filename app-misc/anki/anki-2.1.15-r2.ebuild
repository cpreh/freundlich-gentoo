# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{3_6,3_7} )
PYTHON_REQ_USE="sqlite"

inherit eutils python-single-r1 xdg

DESCRIPTION="A spaced-repetition memory training program (flash cards)"
HOMEPAGE="https://apps.ankiweb.net"

SRC_URI="https://apps.ankiweb.net/downloads/current/${P}-source.tgz -> ${P}.tgz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+recording +sound"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/PyQt5[gui,svg,webchannel,widgets,${PYTHON_MULTI_USEDEP}]
		|| (
			dev-python/PyQtWebEngine[${PYTHON_MULTI_USEDEP}]
			dev-python/PyQt5[webengine]
		)
		>=dev-python/httplib2-0.7.4[${PYTHON_MULTI_USEDEP}]
		dev-python/beautifulsoup:4[${PYTHON_MULTI_USEDEP}]
		dev-python/decorator[${PYTHON_MULTI_USEDEP}]
		dev-python/jsonschema[${PYTHON_MULTI_USEDEP}]
		dev-python/markdown[${PYTHON_MULTI_USEDEP}]
		dev-python/pyaudio[${PYTHON_MULTI_USEDEP}]
		dev-python/requests[${PYTHON_MULTI_USEDEP}]
		dev-python/send2trash[${PYTHON_MULTI_USEDEP}]
	')
	recording? ( media-sound/lame )
	sound? ( media-video/mpv )
"
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}"/${PN}-2.1.0_beta25-web-folder.patch )

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default
	sed -i -e "s/updates=True/updates=False/" \
		aqt/profiles.py || die
}

src_compile() {
	:;
}

src_install() {
	doicon ${PN}.png
	domenu ${PN}.desktop
	doman ${PN}.1

	dodoc README.md README.development
	python_domodule aqt anki
	python_newscript runanki anki

	# Localization files go into the anki directory:
	python_moduleinto anki
	python_domodule locale

	# not sure if this is correct, but
	# site-packages/aqt/mediasrv.py wants the directory
	insinto /usr/share/anki
	doins -r web
}
