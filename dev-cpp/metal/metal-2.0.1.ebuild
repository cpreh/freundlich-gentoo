# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Metal is a single-header C++11 library designed to make you love template metaprogramming."
HOMEPAGE="https://github.com/brunocodutra/metal"
SRC_URI="https://github.com/brunocodutra/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	doheader -r include/metal
	doheader include/metal.hpp
}
