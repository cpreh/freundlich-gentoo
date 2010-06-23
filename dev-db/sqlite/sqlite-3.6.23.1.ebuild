# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.6.23.1.ebuild,v 1.4 2010/06/04 19:25:54 phajdan.jr Exp $

EAPI="3"

inherit autotools eutils flag-o-matic multilib versionator

DESCRIPTION="A SQL Database Engine in a C Library"
HOMEPAGE="http://www.sqlite.org/"
DOC_BASE="$(get_version_component_range 1-3)"
DOC_PV="$(replace_all_version_separators _ ${DOC_BASE})"

SRC_URI="
	tcl? ( http://www.sqlite.org/${P}.tar.gz )
	!tcl? (
		test? ( http://www.sqlite.org/${P}.tar.gz )
		!test? ( http://www.sqlite.org/${PN}-amalgamation-${PV}.tar.gz )
	)
	doc? ( http://www.sqlite.org/${PN}_docs_${DOC_PV}.zip )"

LICENSE="as-is"
SLOT="3"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~ppc-aix ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug doc extensions +fts3 icu +readline secure-delete soundex tcl +threadsafe test unlock-notify"

RDEPEND="icu? ( dev-libs/icu )
	readline? ( sys-libs/readline )
	tcl? ( dev-lang/tcl )"
DEPEND="${RDEPEND}
	test? ( dev-lang/tcl )
	doc? ( app-arch/unzip )"

src_prepare() {
	if use icu; then
		rm -f test/like.test
	fi

	if use tcl || use test; then
		epatch "${FILESDIR}/${PN}-3.6.22-interix-fixes.patch"
		epatch "${FILESDIR}/${PN}-3.6.22-dlopen.patch"  # bug 300836
		eautoreconf  # dlopen.patch patches configure.ac
	else
		epatch "${FILESDIR}/${PN}-3.6.22-interix-fixes-amalgamation.patch"
	fi

	eautoreconf  # for MiNT and interix
	epunt_cxx
}

src_configure() {
	# Support column metadata, bug #266651
	append-cppflags -DSQLITE_ENABLE_COLUMN_METADATA

	# Support R-trees, bug #257646
	append-cppflags -DSQLITE_ENABLE_RTREE

	if use icu; then
		append-cppflags -DSQLITE_ENABLE_ICU
		if use tcl || use test; then
			# Normal tarball.
			sed -e "s/TLIBS = @LIBS@/& -licui18n -licuuc/" -i Makefile.in || die "sed failed"
		else
			# Amalgamation tarball.
			sed -e "s/LIBS = @LIBS@/& -licui18n -licuuc/" -i Makefile.in || die "sed failed"
		fi
	fi

	# Support FTS3, bug #207701
	if use fts3; then
		append-cppflags -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS
	fi

	# Enable secure_delete pragma by default
	if use secure-delete; then
		append-cppflags -DSQLITE_SECURE_DELETE -DSQLITE_CHECK_PAGES -DSQLITE_CORE
	fi

	if use unlock-notify; then
		append-cppflags -DSQLITE_ENABLE_UNLOCK_NOTIFY
	fi

	# Support soundex, bug #143794
	if use soundex; then
		append-cppflags -DSQLITE_SOUNDEX
	fi

	# The amalgamation source doesn't have these via Makefile
	if use debug; then
		append-cppflags -DSQLITE_DEBUG
	else
		append-cppflags -DNDEBUG
	fi

	local extensions_option
	if use tcl || use test; then
		extensions_option="load-extension"
	else
		extensions_option="dynamic-extensions"
	fi

	# Starting from 3.6.23, SQLite has locking strategies that are specific to
	# OSX.  By default they are enabled, and use semantics that only make sense
	# on OSX.  However, they require gethostuuid() function for that, which is
	# only available on OSX starting from 10.6 (Snow Leopard).  For earlier
	# versions of OSX we have to disable all this nifty locking options, as
	# suggested by upstream.
	if [[ "${CHOST}" == *-darwin[56789] ]] ; then
		append-cppflags -DSQLITE_ENABLE_LOCKING_STYLE=0
	fi

	# `configure` from amalgamation tarball doesn't support
	# --with-readline-inc and --(enable|disable)-tcl options.
	econf \
		$(use_enable extensions ${extensions_option}) \
		$(use_enable readline) \
		$({ use tcl || use test; } && echo --with-readline-inc="-I${EPREFIX}/usr/include/readline") \
		$(use_enable threadsafe) \
		$(use tcl && echo --enable-tcl) \
		$(use !tcl && use test && echo --enable-tcl)
}

src_compile() {
	emake TCLLIBDIR="${EPREFIX}/usr/$(get_libdir)/${P}" || die "emake failed"
}

src_test() {
	if [[ "${EUID}" -ne "0" ]]; then
		local test="test"
		use debug && test="fulltest"
		emake ${test} || die "Some test(s) failed"
	else
		ewarn "The userpriv feature must be enabled to run tests."
		eerror "Testsuite will not be run."
	fi
}

src_install() {
	emake \
		DESTDIR="${D}" \
		TCLLIBDIR="${EPREFIX}/usr/$(get_libdir)/${P}" \
		install \
		|| die "emake install failed"

	doman sqlite3.1 || die "doman sqlite3.1 failed"

	if use doc; then
		# Naming scheme changes randomly between - and _ in releases
		# http://www.sqlite.org/cvstrac/tktview?tn=3523
		dohtml -r "${WORKDIR}"/${PN}-${DOC_PV}-docs/* || die "dohtml failed"
	fi
}
