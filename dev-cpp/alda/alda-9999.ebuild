# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8

inherit cmake git-r3

DESCRIPTION="A serialization library"
HOMEPAGE=""
EGIT_REPO_URI="https://github.com/cpreh/alda.git"

LICENSE="LGPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+net static-libs test"

RDEPEND="
	~dev-cpp/fcppt-9999
	net? (
		>=dev-libs/boost-1.50:=
	)
	"
DEPEND="
	${RDEPEND}
	test? (
		dev-cpp/catch
		dev-cpp/fcppt[catch]
	)
"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_NET="$(usex net)"
		-D ENABLE_STATIC="$(usex static-libs)"
		-D ENABLE_TEST="$(usex test)"
	)

	cmake_src_configure
}
