# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="gcc-compiler"
GCC_FILESDIR=${PORTDIR}/sys-devel/gcc/files

inherit multilib subversion toolchain

DESCRIPTION="The GNU Compiler Collection.  Includes C/C++, java compilers, pie+ssp extensions, Haj Ten Brugge runtime bounds checking"
HOMEPAGE="http://gcc.gnu.org/"
ESVN_REPO_URI="svn://gcc.gnu.org/svn/gcc/branches/gcc-4_5-branch"
SRC_URI=""

IUSE="debug lto offline"

LICENSE="GPL-3 LGPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1"
KEYWORDS=""
SLOT="${GCC_BRANCH_VER}-svn"
SPLIT_SPECS="no"
PRERELEASE="yes"

RDEPEND=">=sys-libs/zlib-1.1.4
	>=sys-devel/gcc-config-1.4
	virtual/libiconv
	>=dev-libs/gmp-4.2.2
	>=dev-libs/mpfr-2.3.2
	>=dev-libs/mpc-0.8
	graphite? (
		>=dev-libs/ppl-0.10
		>=dev-libs/cloog-ppl-0.15.8
	)
	lto? ( >=dev-libs/elfutils-0.143 )
	!build? (
		gcj? (
			gtk? (
				x11-libs/libXt
				x11-libs/libX11
				x11-libs/libXtst
				x11-proto/xproto
				x11-proto/xextproto
				>=x11-libs/gtk+-2.2
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
			app-arch/zip
			app-arch/unzip
		)
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	test? ( >=dev-util/dejagnu-1.4.4 >=sys-devel/autogen-5.5.4 )
	>=sys-apps/texinfo-4.8
	>=sys-devel/bison-1.875
	>=sys-devel/flex-2.5.4
	amd64? ( multilib? ( gcj? ( app-emulation/emul-linux-x86-xlibs ) ) )
	>=${CATEGORY}/binutils-2.18"
PDEPEND=">=sys-devel/gcc-config-1.4"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

src_unpack() {
	export BRANDING_GCC_PKGVERSION="Gentoo SVN"

	[[ -z ${UCLIBC_VER} ]] && [[ ${CTARGET} == *-uclibc* ]] && die "Sorry, this version does not support uClibc"

	# use the offline USE flag to prevent the ebuild from trying to update from
	# the repo.  the current sources will be used instead.
	use offline && ESVN_OFFLINE="yes"

	subversion_src_unpack

	cd "${S}"

	gcc_version_patch

	subversion_wc_info
	echo ${PV/_/-} > "${S}"/gcc/BASE-VER
	echo "rev. ${ESVN_WC_REVISION}" > "${S}"/gcc/REVISION

	if ! use vanilla ; then
		EPATCH_SOURCE="${FILESDIR}/${GCC_RELEASE_VER}" \
		EPATCH_EXCLUDE="${FILESDIR}/${GCC_RELEASE_VER}/exclude" \
		EPATCH_FORCE="yes" EPATCH_SUFFIX="patch" epatch \
		|| die "Failed during patching."
	fi

	${ETYPE}_src_unpack || die "failed to ${ETYPE}_src_unpack"

	# protoize don't build on FreeBSD, skip it
	## removed in 4.5, bug #270558 --de.
	if [[ ${GCCMAJOR}.${GCCMINOR} < 4.5 ]]; then
		if ! is_crosscompile && ! use elibc_FreeBSD ; then
			# enable protoize / unprotoize
			sed -i -e '/^LANGUAGES =/s:$: proto:' "${S}"/gcc/Makefile.in
		fi
	fi

	fix_files=""
	for x in contrib/test_summary libstdc++-v3/scripts/check_survey.in ; do
		[[ -e ${x} ]] && fix_files="${fix_files} ${x}"
	done
	ht_fix_file ${fix_files} */configure *.sh */Makefile.in

	if ! is_crosscompile && is_multilib && \
		[[ ( $(tc-arch) == "amd64" || $(tc-arch) == "ppc64" ) && -z ${SKIP_MULTILIB_HACK} ]] ; then
			disgusting_gcc_multilib_HACK || die "multilib hack failed"
	fi

	# >= gcc-4.3 doesn't bundle ecj.jar, so copy it
	if [[ ${GCCMAJOR}.${GCCMINOR} > 4.2 ]] &&
		use gcj ; then
		cp -pPR "${DISTDIR}/ecj-4.3.jar" "${S}/ecj.jar" || die
	fi

	# Fixup libtool to correctly generate .la files with portage
	cd "${S}"
	elibtoolize --portage --shallow --no-uclibc

	gnuconfig_update

	# update configure files
	local f
	einfo "Fixing misc issues in configure files"
	tc_version_is_at_least 4.1 && epatch "${GCC_FILESDIR}"/gcc-configure-texinfo.patch
	for f in $(grep -l 'autoconf version 2.13' $(find "${S}" -name configure)) ; do
		ebegin "  Updating ${f/${S}\/} [LANG]"
		patch "${f}" "${GCC_FILESDIR}"/gcc-configure-LANG.patch >& "${T}"/configure-patch.log \
			|| eerror "Please file a bug about this"
		eend $?
	done
	sed -i 's|A-Za-z0-9|[:alnum:]|g' "${S}"/gcc/*.awk #215828

	if [[ -x contrib/gcc_update ]] ; then
		einfo "Touching generated files"
		./contrib/gcc_update --touch | \
			while read f ; do
				einfo "  ${f%%...}"
			done
	fi

	disable_multilib_libjava || die "failed to disable multilib java"

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${GCC_FILESDIR}"/gcc-spec-env.patch
	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${GCC_FILESDIR}"/4.4.0/gcc-4.4.0-softfloat.patch
	# Fix cross-compiling
	epatch "${GCC_FILESDIR}"/4.1.0/gcc-4.1.0-cross-compile.patch

	EXTRA_ECONF="$(use_enable debug checking) ${EXTRA_ECONF}"
	EXTRA_ECONF="$(use_enable lto) ${EXTRA_ECONF}"
}

src_install() {
	toolchain_src_install

	# Move pretty-printers to gdb datadir to shut ldconfig up
	gdbdir=/usr/share/gdb/auto-load
	for module in $(find "${D}" -iname "*-gdb.py" -print); do
		insinto ${gdbdir}/$(dirname "${module/${D}/}" | sed -e "s:/lib/:/$(get_libdir)/:g")
		doins "${module}"
		rm "${module}"
	done
}

pkg_preinst() {
	toolchain_pkg_preinst
	subversion_pkg_preinst
}
