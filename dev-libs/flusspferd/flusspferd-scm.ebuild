# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EGIT_HAS_SUBMODULES=true

inherit cmake-utils git

EAPI="3"

EGIT_REPO_URI="git://github.com/ruediger/flusspferd.git"

DESCRIPTION="Javascript bindings for C++"
HOMEPAGE="http://flusspferd.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion curl doc emacs gmp libedit readline sqlite3 subprocess xml test"

DEPEND="
	>=dev-lang/spidermonkey-1.8
	>=dev-libs/boost-1.40.0
	curl? ( net-misc/curl )
	doc? (
		app-doc/doxygen
		dev-ruby/maruku
		dev-ruby/rake
		dev-ruby/treetop
		sys-apps/groff
		virtual/rubygems
	)
	gmp? ( dev-libs/gmp )
	libedit? ( dev-libs/libedit )
	readline? ( sys-libs/readline )
	sqlite3? ( >=dev-db/sqlite-3 )
	xml? ( dev-libs/arabica )
"

RDEPEND="${DEPEND}"

pkg_setup() {
	use libedit && use readline && die "Please enable only one of the use flagss libedit readline"
}

src_configure() {
	local mycmakeargs="-DFORCE_PLUGINS=ON -DFORCE_LINE_EDITOR=ON $(cmake-utils_use_enable test TESTS)"

	use libedit || use readline || mycmakeargs+=" -DLINE_EDITOR=none"
	use bash-completion || mycmakeargs+=" -DBASH_COMPLETION=OFF"
	use curl || mycmakeargs+=" -DPLUGIN_CURL=OFF"
	use doc && mycmakeargs+=" -DCREATE_DOCUMENTATION=ON"
	use emacs || mycmakeargs+=" -DEMACS_MODE=OFF"
	use gmp || mycmakeargs+=" -DPLUGIN_GMP=OFF"
	use libedit && mycmakeargs+=" -DLINE_EDITOR=libedit"
	use readline && mycmakeargs+=" -DLINE_EDITOR=readline"
	use sqlite3 || mycmakeargs+=" -DPLUGIN_SQLITE3=OFF"
	use subprocess || mycmakeargs+=" -DPLUGIN_SUBPROCESS=OFF"
	use xml || mycmakeargs+=" -DPLUGIN_XML=OFF"

	cmake-utils_src_configure
}
