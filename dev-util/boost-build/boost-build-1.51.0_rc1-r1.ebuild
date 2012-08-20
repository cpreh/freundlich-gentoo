# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/boost-build/boost-build-1.50.0-r1.ebuild,v 1.2 2012/08/19 18:26:58 dev-zero Exp $

EAPI="4"
RESTRICT="mirror"
PYTHON_DEPEND="python? 2"

inherit eutils flag-o-matic python toolchain-funcs versionator

MY_PV="$(replace_all_version_separators _)"
MY_DIR="$(replace_all_version_separators _ $(get_version_component_range 1-3))"
MAJOR_PV="$(replace_all_version_separators _ $(get_version_component_range 1-2))"

DESCRIPTION="A system for large project software construction, which is simple to use and powerful."
HOMEPAGE="http://www.boost.org/doc/tools/build/index.html"
SRC_URI="http://boost.cowic.de/rc/boost_${MY_PV}.tar.bz2"

LICENSE="Boost-1.0"
SLOT="$(get_version_component_range 1-2)"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="examples python test"

RDEPEND="!<dev-libs/boost-1.34.0
	!<=dev-util/boost-build-1.35.0-r1"
DEPEND="${RDEPEND}
	test? ( =dev-lang/python-2*
		sys-apps/diffutils )"

S="${WORKDIR}/boost_${MY_DIR}/tools/build/v2"

pkg_setup() {
	if use python ; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_unpack() {
	tar xjpf "${DISTDIR}/${A}" ./boost_${MY_DIR}/tools/build/v2 || die "unpacking tar failed"
}

src_prepare() {
	epatch \
		"${FILESDIR}/${PN}-1.48.0-support_dots_in_python-buildid.patch" \
		"${FILESDIR}/${PN}-1.48.0-disable_python_rpath.patch" \
		"${FILESDIR}/${PN}-1.50.0-respect-c_ld-flags.patch" \
		"${FILESDIR}/${PN}-1.50.0-fix-test.patch"

	# Remove stripping option
	cd "${S}/engine"
	sed -i -e 's|-s\b||' \
		build.jam || die "sed failed"

	# Force regeneration
	rm jambase.c || die

	# This patch allows us to fully control optimization
	# and stripping flags when bjam is used as build-system
	# We simply extend the optimization and debug-symbols feature
	# with empty dummies called 'none'
	cd "${S}"
	sed -i \
		-e 's/\(off speed space\)/\1 none/' \
		-e 's/\(debug-symbols      : on off\)/\1 none/' \
		tools/builtin.jam || die "sed failed"
}

src_configure() {
	# - install versioned tools
	# - install into versioned directory
	# - don't install examples
	sed -i \
		-e "s|b2|b2-${MAJOR_PV}|" \
		-e "s|bjam|bjam-${MAJOR_PV}|" \
		-e "s|    boost-build|boost-build-${MAJOR_PV}|" \
		-e '/$(e2)/d' \
		Jamroot.jam || die "sed failed"

	# For slotting
	sed -i \
		-e "s|/usr/share/boost-build|/usr/share/boost-build-${MAJOR_PV}|" \
		engine/Jambase || die "sed failed"

	if use python ; then
		# replace versions by user-selected one (TODO: fix this when slot-op
		# deps are available to always match the best version available)
		sed -i \
			-e "s|2.7 2.6 2.5 2.4 2.3 2.2|${PYTHON_ABI}|" \
			engine/build.jam || die "sed failed"
	fi
}

src_compile() {
	cd engine

	local toolset

	if [[ ${CHOST} == *-darwin* ]] ; then
		toolset=darwin
	else
		# Using boost's generic toolset here, which respects CC and CFLAGS
		toolset=cc
	fi

	CC=$(tc-getCC) ./build.sh ${toolset} -d+2 $(use_with python python /usr) || die "building bjam failed"
}

src_install() {
	newbin engine/bin.*/bjam bjam-${MAJOR_PV}
	newbin engine/bin.*/b2 b2-${MAJOR_PV}

	insinto /usr/share/boost-build-${MAJOR_PV}
	doins -r boost-build.jam bootstrap.jam build-system.jam site-config.jam user-config.jam *.py \
		build kernel options tools util || die

	rm "${D}/usr/share/boost-build-${MAJOR_PV}/build/project.ann.py" || die "removing faulty python file failed"
	use python || find "${D}/usr/share/boost-build-${MAJOR_PV}" -iname "*.py" -delete || die "removing experimental python files failed"

	dodoc changes.txt hacking.txt release_procedure.txt \
		notes/build_dir_option.txt notes/relative_source_paths.txt

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r example
	fi
}

src_test() {
	cd test

	export TMP="${T}"

	DO_DIFF="${PREFIX}/usr/bin/diff" $(PYTHON -2) test_all.py

	if [ -s test_results.txt ] ; then
		eerror "At least one test failed: $(<test_results.txt)"
		die "tests failed"
	fi
}

pkg_postinst() {
	use python && python_mod_optimize /usr/share/boost-build-${MAJOR_PV}/{build,kernel,tools,tools/doxygen,util}
}

pkg_postrm() {
	use python && python_mod_cleanup /usr/share/boost-build-${MAJOR_PV}/{build,kernel,tools,tools/doxygen,util}
}
