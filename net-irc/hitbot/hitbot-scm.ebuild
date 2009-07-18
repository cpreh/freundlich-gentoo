# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

CABAL_FEATURES="bin"
inherit haskell-cabal git
EGIT_REPO_URI="git://freundlich.mine.nu/hitbot.git"

DESCRIPTION="A small IRC bot which logs git commits"
HOMEPAGE=""

LICENSE="GPL"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-lang/ghc-6.10.3
         dev-haskell/network
         dev-haskell/filepath"

DEPEND="${RDEPEND}
        >=dev-haskell/cabal-1.2"
