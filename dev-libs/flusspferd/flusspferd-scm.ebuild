# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit cmake-utils git

EAPI="2"

EGIT_REPO_URI="git://github.com/ruediger/flusspferd.git"

DESCRIPTION="Javascript bindings for C++"
HOMEPAGE="http://flusspferd.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="curl doc gmp libedit readline sqlite3 subprocess test"

#TODO: add xml and arabica

DEPEND="
	>=dev-lang/spidermonkey-1.8
	>=dev-libs/boost-1.40.0
	curl? ( net-misc/curl )
	doc? ( app-doc/doxygen )
	gmp? ( dev-libs/gmp )
	libedit? ( dev-libs/libedit )
	readline? ( sys-libs/readline )
	sqlite3? ( >=dev-db/sqlite-3 )
"

RDEPEND="${DEPEND}"

pkg_setup() {
	use libedit && use readline && die "Please enable only one of the use flagss libedit readline"
}

src_configure() {
	local mycmakeargs="-D FORCE_PLUGINS:=ON -D FORCE_LINE_EDITOR:=ON -D PLUGIN_XML:=OFF $(cmake-utils_use_enable test TESTS)"

	use libedit || use readline || mycmakeargs+=" -D LINE_EDITOR:=none"
	use curl || mycmakeargs+=" -D PLUGIN_CURL:=OFF"
	use doc && mycmakeargs+=" -D CREATE_DOCUMENTATION:=ON"
	use gmp || mycmakeargs+=" -D PLUGIN_GMP:=OFF"
	use libedit && mycmakeargs+=" -D LINE_EDITOR:=libedit"
	use readline && mycmakeargs+=" -D LINE_EDITOR:=readline"
	use sqlite3 || mycmakeargs+=" -D PLUGIN_SQLITE3:=OFF"
	use subprocess || mycmakeargs+=" -D PLUGIN_SUBPROCESS:=OFF"
	use xml || mycmakeargs+=" -D PLUGIN_XML:=OFF"

	echo ${mycmakeargs}

	cmake-utils_src_configure
}
