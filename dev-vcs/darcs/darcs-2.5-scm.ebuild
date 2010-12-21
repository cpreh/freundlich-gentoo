# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

# ebuild generated by hackport 0.2.9

EAPI="2"
CABAL_FEATURES="bin lib profile haddock hscolour"
inherit haskell-cabal eutils bash-completion darcs

DESCRIPTION="a distributed, interactive, smart revision control system"
HOMEPAGE="http://darcs.net/"
EDARCS_REPOSITORY="http://darcs.vm.spiny.org.uk/~ganesh/darcs-2.5-ghc7-2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="doc test"

RDEPEND="~dev-haskell/hashed-storage-0.5.2
		<dev-haskell/haskeline-0.7
		=dev-haskell/html-1.0*
		<dev-haskell/http-4000.1
		=dev-haskell/mmap-0.5*
		<dev-haskell/mtl-2
		=dev-haskell/network-2*
		<dev-haskell/parsec-3.1
		<dev-haskell/regex-compat-0.94
		=dev-haskell/tar-0.3*
		=dev-haskell/terminfo-0.3*
		>=dev-haskell/text-0.3
		<dev-haskell/zlib-0.6.0.0
		>=dev-lang/ghc-6.10.1
		<dev-haskell/containers-0.5
		=dev-haskell/filepath-1.1*
		=dev-haskell/directory-1.0*
		net-misc/curl
		virtual/mta"

# darcs also has a library version; we thus need $DEPEND
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.8
		doc?  ( virtual/latex-base
				dev-tex/latex2html )
		test? ( dev-haskell/test-framework
				dev-haskell/test-framework-hunit
				dev-haskell/test-framework-quickcheck2 )
		"

pkg_setup() {
	if use doc && ! built_with_use -o dev-tex/latex2html png gif; then
		eerror "Building darcs with USE=\"doc\" requires that"
		eerror "dev-tex/latex2html is built with at least one of"
		eerror "USE=\"png\" and USE=\"gif\"."
		die "USE=doc requires dev-tex/latex2html with USE=\"png\" or USE=\"gif\""
	fi
}

src_prepare() {
	pushd "contrib"
	epatch "${FILESDIR}/${PN}-1.0.9-bashcomp.patch"
	popd

	# hlint tests tend to break on every newly released hlint
	rm "${S}/tests/haskell_policy.sh"
}

src_configure() {
	# checking whether ghc supports -threaded flag
	# Beware: http://www.haskell.org/ghc/docs/latest/html/users_guide/options-phases.html#options-linker
	# contains: 'The ability to make a foreign call that does not block all other Haskell threads.'
	# It might have interactivity impact.

	threaded_flag=""
	if $(ghc-getghc) --info | grep "Support SMP" | grep -q "YES"; then
		threaded_flag="--flags=threaded"
		einfo "$P will be built with threads support"
	else
		threaded_flag="--flags=-threaded"
		einfo "$P will be built without threads support"
	fi

	# Use curl for net stuff to avoid strict version dep on HTTP and network
	cabal_src_configure \
		--flags=curl \
		--flags=-http \
		--flags=curl-pipelining \
		--flags=color \
		--flags=terminfo \
		--flags=mmap \
		$threaded_flag \
		$(cabal_flag test)
}

src_test() {
	# run cabal test from haskell-cabal
	haskell-cabal_src_test || die "cabal test failed"

	# run the unit tests (not part of cabal test for some reason...)
	# breaks the cabal abstraction a bit...
	"${S}/dist/build/unit/unit" || die "unit tests failed"
}

src_install() {
	cabal_src_install
	dobashcompletion "${S}/contrib/darcs_completion" "${PN}"

	rm "${D}/usr/bin/unit" 2> /dev/null

	# fixup perms in such an an awkward way
	mv "${D}/usr/share/man/man1/darcs.1" "${S}/darcs.1" || die "darcs.1 not found"
	doman "${S}/darcs.1" || die "failed to register darcs.1 as a manpage"

	# if tests were enabled, make sure the unit test driver is deleted
	rm -rf "${D}/usr/bin/unit"
}

pkg_postinst() {
	ghc-package_pkg_postinst
	bash-completion_pkg_postinst

	ewarn "NOTE: in order for the darcs send command to work properly,"
	ewarn "you must properly configure your mail transport agent to relay"
	ewarn "outgoing mail.  For example, if you are using ssmtp, please edit"
	ewarn "/etc/ssmtp/ssmtp.conf with appropriate values for your site."
}
