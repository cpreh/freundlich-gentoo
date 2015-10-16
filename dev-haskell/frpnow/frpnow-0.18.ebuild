# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

CABAL_FEATURES="lib haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="FRP with first-class behaviors and interalized IO, without space leaks"
HOMEPAGE="https://github.com/atzeus/FRPNow"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-haskell/mtl-1.0:=
	dev-haskell/transformers:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.6
"
