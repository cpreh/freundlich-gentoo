# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit base

EAPI=4

DESCRIPTION="a powerful application launcher by running a specialized bash session"
HOMEPAGE="http://code.google.com/p/bashrun2/"
SRC_URI="http://bashrun2.googlecode.com/files/bashrun2-0.2.2.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="x11-libs/libX11
		x11-proto/xproto
		sys-apps/sed
		>=app-shells/bash-4.1
		sys-apps/grep
		sys-libs/ncurses
		sys-process/procps
		x11-terms/xterm"
RDEPEND="${DEPEND}"
