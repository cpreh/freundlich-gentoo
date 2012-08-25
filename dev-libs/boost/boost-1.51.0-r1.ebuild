# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/boost/boost-1.50.0-r2.ebuild,v 1.1 2012/08/24 09:46:08 dev-zero Exp $

EAPI="4"
RESTRICT="mirror"
PYTHON_DEPEND="python? *"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="*-jython *-pypy-*"

inherit check-reqs flag-o-matic multilib multiprocessing python toolchain-funcs versionator

MY_P=${PN}_$(replace_all_version_separators _)

DESCRIPTION="Boost Libraries for C++"
HOMEPAGE="http://www.boost.org/"
SRC_URI="mirror://sourceforge/boost/${MY_P}.tar.bz2"

LICENSE="Boost-1.0"
SLOT="$(get_version_component_range 1-2)"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="debug doc icu mpi python static-libs test tools"

RDEPEND="icu? ( >=dev-libs/icu-3.6 )
	!icu? ( virtual/libiconv )
	mpi? ( || ( sys-cluster/openmpi[cxx] sys-cluster/mpich2[cxx,threads] ) )
	sys-libs/zlib
	!!<=dev-libs/boost-1.35.0-r2"
DEPEND="${RDEPEND}
	>=dev-util/boost-build-1.50.0-r2:${SLOT}"

S="${WORKDIR}/${MY_P}"

MAJOR_PV=$(replace_all_version_separators _ ${SLOT})
BJAM="b2-${MAJOR_PV}"

create_user-config.jam() {
	local compiler compiler_version compiler_executable

	if [[ ${CHOST} == *-darwin* ]]; then
		compiler="darwin"
		compiler_version="$(gcc-fullversion)"
		compiler_executable="$(tc-getCXX)"
	else
		compiler="gcc"
		compiler_version="$(gcc-version)"
		compiler_executable="$(tc-getCXX)"
	fi
	local mpi_configuration python_configuration

	if use mpi; then
		mpi_configuration="using mpi ;"
	fi

	if use python; then
		python_configuration="using python : $(python_get_version) : /usr : $(python_get_includedir) : /usr/$(get_libdir) ;"
	fi

	cat > user-config.jam << __EOF__
using ${compiler} : ${compiler_version} : ${compiler_executable} : <cflags>"${CFLAGS}" <cxxflags>"${CXXFLAGS}" <linkflags>"${LDFLAGS}" ;
${mpi_configuration}
${python_configuration}
__EOF__
}

pkg_pretend() {
	if use test; then
		CHECKREQS_DISK_BUILD="15G" check-reqs_pkg_pretend

		ewarn "The tests may take several hours on a recent machine"
		ewarn "but they will not fail (unless something weird happens ;-)"
		ewarn "This is because the tests depend on the used compiler version"
		ewarn "and the platform and upstream says that this is normal."
		ewarn "If you are interested in the results, please take a look at the"
		ewarn "generated results page:"
		ewarn "  ${ROOT}usr/share/doc/${PF}/status/cs-$(uname).html"
	fi
}

pkg_setup() {
	if use python; then
		python_pkg_setup
	fi

	if use debug; then
		ewarn "The debug USE flag means that a second set of the boost libraries"
		ewarn "will be built containing debug symbols. But even though the optimization flags"
		ewarn "you might have set are not stripped, there will be a performance"
		ewarn "penalty and linking other packages against the debug version"
		ewarn "of boost is _not_ recommended."
	fi
}

src_prepare() {
	epatch \
		"${FILESDIR}/${PN}-1.48.0-mpi_python3.patch" \
		"${FILESDIR}/${PN}-1.51.0-respect_python-buildid.patch" \
		"${FILESDIR}/${PN}-1.48.0-support_dots_in_python-buildid.patch" \
		"${FILESDIR}/${PN}-1.48.0-no_strict_aliasing_python2.patch" \
		"${FILESDIR}/${PN}-1.48.0-disable_libboost_python3.patch" \
		"${FILESDIR}/${PN}-1.48.0-python_linking.patch" \
		"${FILESDIR}/${PN}-1.48.0-disable_icu_rpath.patch" \
		"${FILESDIR}/remove-toolset-1.48.0.patch"
}

src_configure() {
	OPTIONS=""

	if [[ ${CHOST} == *-darwin* ]]; then
		# We need to add the prefix, and in two cases this exceeds, so prepare
		# for the largest possible space allocation.
		append-ldflags -Wl,-headerpad_max_install_names
	fi

	# bug 298489
	if use ppc || use ppc64; then
		[[ $(gcc-version) > 4.3 ]] && append-flags -mno-altivec
	fi

	use icu && OPTIONS+=" -sICU_PATH=/usr"
	use icu || OPTIONS+=" --disable-icu boost.locale.icu=off"
	use mpi || OPTIONS+=" --without-mpi"
	use python || OPTIONS+=" --without-python"

	# https://svn.boost.org/trac/boost/attachment/ticket/2597/add-disable-long-double.patch
	if use sparc || { use mips && [[ ${ABI} = "o32" ]]; } || use hppa || use arm || use x86-fbsd || use sh; then
		OPTIONS+=" --disable-long-double"
	fi

	OPTIONS+=" pch=off --boost-build=/usr/share/boost-build-${MAJOR_PV} --prefix=\"${D}usr\" --layout=versioned"

	if use static-libs; then
		LINK_OPTS="link=shared,static"
		LIBRARY_TARGETS="*.a *$(get_libname)"
	else
		LINK_OPTS="link=shared"
		# There is no dynamically linked version of libboost_test_exec_monitor and libboost_exception.
		LIBRARY_TARGETS="libboost_test_exec_monitor*.a libboost_exception*.a *$(get_libname)"
	fi
}

src_compile() {
	export BOOST_ROOT="${S}"
	PYTHON_DIRS=""
	MPI_PYTHON_MODULE=""
	NUMJOBS="-j$(makeopts_jobs)"

	building() {
		create_user-config.jam

		einfo "Using the following command to build:"
		einfo "${BJAM} ${NUMJOBS} -q -d+2 gentoorelease --user-config=user-config.jam ${OPTIONS} threading=single,multi ${LINK_OPTS} $(use python && echo --python-buildid=${PYTHON_ABI})"

		${BJAM} ${NUMJOBS} -q -d+2 \
			gentoorelease \
			--user-config=user-config.jam \
			${OPTIONS} threading=single,multi ${LINK_OPTS} \
			$(use python && echo --python-buildid=${PYTHON_ABI}) \
			|| die "Building of Boost libraries failed"

		# ... and do the whole thing one more time to get the debug libs
		if use debug; then
			einfo "Using the following command to build:"
			einfo "${BJAM} ${NUMJOBS} -q -d+2 gentoodebug --user-config=user-config.jam ${OPTIONS} threading=single,multi ${LINK_OPTS} --buildid=debug $(use python && echo --python-buildid=${PYTHON_ABI})"

			${BJAM} ${NUMJOBS} -q -d+2 \
				gentoodebug \
				--user-config=user-config.jam \
				${OPTIONS} threading=single,multi ${LINK_OPTS} \
				--buildid=debug \
				$(use python && echo --python-buildid=${PYTHON_ABI}) \
				|| die "Building of Boost debug libraries failed"
		fi

		if use python; then
			if [[ -z "${PYTHON_DIRS}" ]]; then
				PYTHON_DIRS="$(find bin.v2/libs -name python | sort)"
			else
				if [[ "${PYTHON_DIRS}" != "$(find bin.v2/libs -name python | sort)" ]]; then
					die "Inconsistent structure of build directories"
				fi
			fi

			local dir
			for dir in ${PYTHON_DIRS}; do
				mv ${dir} ${dir}-${PYTHON_ABI} || die "Renaming of '${dir}' to '${dir}-${PYTHON_ABI}' failed"
			done

			if use mpi; then
				if [[ -z "${MPI_PYTHON_MODULE}" ]]; then
					MPI_PYTHON_MODULE="$(find bin.v2/libs/mpi/build/*/gentoorelease -name mpi.so)"
					if [[ "$(echo "${MPI_PYTHON_MODULE}" | wc -l)" -ne 1 ]]; then
						die "Multiple mpi.so files found"
					fi
				else
					if [[ "${MPI_PYTHON_MODULE}" != "$(find bin.v2/libs/mpi/build/*/gentoorelease -name mpi.so)" ]]; then
						die "Inconsistent structure of build directories"
					fi
				fi

				mv stage/lib/mpi.so stage/lib/mpi.so-${PYTHON_ABI} || die "Renaming of 'stage/lib/mpi.so' to 'stage/lib/mpi.so-${PYTHON_ABI}' failed"
			fi
		fi
	}
	if use python; then
		python_execute_function building
	else
		building
	fi

	if use tools; then
		pushd tools > /dev/null || die
		einfo "Using the following command to build the tools:"
		einfo "${BJAM} ${NUMJOBS} -q -d+2 gentoorelease --user-config=../user-config.jam ${OPTIONS}"

		${BJAM} ${NUMJOBS} -q -d+2\
			gentoorelease \
			--user-config=../user-config.jam \
			${OPTIONS} \
			|| die "Building of Boost tools failed"
		popd > /dev/null || die
	fi
}

src_install () {
	installation() {
		create_user-config.jam

		if use python; then
			local dir
			for dir in ${PYTHON_DIRS}; do
				cp -pr ${dir}-${PYTHON_ABI} ${dir} || die "Copying of '${dir}-${PYTHON_ABI}' to '${dir}' failed"
			done

			if use mpi; then
				cp -p stage/lib/mpi.so-${PYTHON_ABI} "${MPI_PYTHON_MODULE}" || die "Copying of 'stage/lib/mpi.so-${PYTHON_ABI}' to '${MPI_PYTHON_MODULE}' failed"
				cp -p stage/lib/mpi.so-${PYTHON_ABI} stage/lib/mpi.so || die "Copying of 'stage/lib/mpi.so-${PYTHON_ABI}' to 'stage/lib/mpi.so' failed"
			fi
		fi

		einfo "Using the following command to install:"
		einfo "${BJAM} -q -d+2 gentoorelease --user-config=user-config.jam ${OPTIONS} threading=single,multi ${LINK_OPTS} --includedir=\"${D}usr/include\" --libdir=\"${D}usr/$(get_libdir)\" $(use python && echo --python-buildid=${PYTHON_ABI}) install"

		${BJAM} -q -d+2 \
			gentoorelease \
			--user-config=user-config.jam \
			${OPTIONS} threading=single,multi ${LINK_OPTS} \
			--includedir="${D}usr/include" \
			--libdir="${D}usr/$(get_libdir)" \
			$(use python && echo --python-buildid=${PYTHON_ABI}) \
			install || die "Installation of Boost libraries failed"

		if use debug; then
			einfo "Using the following command to install:"
			einfo "${BJAM} -q -d+2 gentoodebug --user-config=user-config.jam ${OPTIONS} threading=single,multi ${LINK_OPTS} --includedir=\"${D}usr/include\" --libdir=\"${D}usr/$(get_libdir)\" --buildid=debug $(use python && echo --python-buildid=${PYTHON_ABI})"

			${BJAM} -q -d+2 \
				gentoodebug \
				--user-config=user-config.jam \
				${OPTIONS} threading=single,multi ${LINK_OPTS} \
				--includedir="${D}usr/include" \
				--libdir="${D}usr/$(get_libdir)" \
				--buildid=debug \
				$(use python && echo --python-buildid=${PYTHON_ABI}) \
				install || die "Installation of Boost debug libraries failed"
		fi

		if use python; then
			rm -r ${PYTHON_DIRS} || die

			# Move mpi.so Python module to Python site-packages directory and make sure it is slotted.
			if use mpi; then
				mkdir -p "${D}$(python_get_sitedir)/boost_${MAJOR_PV}" || die
				mv "${D}usr/$(get_libdir)/mpi.so" "${D}$(python_get_sitedir)/boost_${MAJOR_PV}" || die
				cat << EOF > "${D}$(python_get_sitedir)/boost_${MAJOR_PV}/__init__.py" || die
import sys
if sys.platform.startswith('linux'):
	import DLFCN
	flags = sys.getdlopenflags()
	sys.setdlopenflags(DLFCN.RTLD_NOW | DLFCN.RTLD_GLOBAL)
	from . import mpi
	sys.setdlopenflags(flags)
	del DLFCN, flags
else:
	from . import mpi
del sys
EOF
			fi
		fi
	}
	if use python; then
		python_execute_function installation
	else
		installation
	fi

	use python || rm -rf "${D}usr/include/boost-${MAJOR_PV}/boost"/python* || die

	if use doc; then
		find libs/*/* -iname "test" -or -iname "src" | xargs rm -rf
		dohtml \
			-A pdf,txt,cpp,hpp \
			*.{htm,html,png,css} \
			-r doc
		dohtml \
			-A pdf,txt \
			-r tools
		insinto /usr/share/doc/${PF}/html
		doins -r libs
		doins -r more

		# To avoid broken links
		insinto /usr/share/doc/${PF}/html
		doins LICENSE_1_0.txt

		dosym /usr/include/boost-${MAJOR_PV}/boost /usr/share/doc/${PF}/html/boost
	fi

	pushd "${D}usr/$(get_libdir)" > /dev/null || die

	# Remove (unversioned) symlinks
	# And check for what we remove to catch bugs
	# got a better idea how to do it? tell me!
	local f
	for f in $(ls -1 ${LIBRARY_TARGETS} | grep -v "${MAJOR_PV}"); do
		if [[ ! -h "${f}" ]]; then
			eerror "Tried to remove '${f}' which is a regular file instead of a symlink"
			die "Slotting/naming of the libraries broken!"
		fi
		rm "${f}" || die
	done

	# The threading libs obviously always gets the "-mt" (multithreading) tag
	# some packages seem to have a problem with it. Creating symlinks...

	if use static-libs; then
		THREAD_LIBS="libboost_thread-mt-${MAJOR_PV}.a libboost_thread-mt-${MAJOR_PV}$(get_libname)"
	else
		THREAD_LIBS="libboost_thread-mt-${MAJOR_PV}$(get_libname)"
	fi
	local lib
	for lib in ${THREAD_LIBS}; do
		dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})"
	done

	# The same goes for the mpi libs
	if use mpi; then
		if use static-libs; then
			MPI_LIBS="libboost_mpi-mt-${MAJOR_PV}.a libboost_mpi-mt-${MAJOR_PV}$(get_libname)"
		else
			MPI_LIBS="libboost_mpi-mt-${MAJOR_PV}$(get_libname)"
		fi
		local lib
		for lib in ${MPI_LIBS}; do
			dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})"
		done
	fi

	if use debug; then
		if use static-libs; then
			THREAD_DEBUG_LIBS="libboost_thread-mt-${MAJOR_PV}-debug$(get_libname) libboost_thread-mt-${MAJOR_PV}-debug.a"
		else
			THREAD_DEBUG_LIBS="libboost_thread-mt-${MAJOR_PV}-debug$(get_libname)"
		fi

		local lib
		for lib in ${THREAD_DEBUG_LIBS}; do
			dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})"
		done

		if use mpi; then
			if use static-libs; then
				MPI_DEBUG_LIBS="libboost_mpi-mt-${MAJOR_PV}-debug.a libboost_mpi-mt-${MAJOR_PV}-debug$(get_libname)"
			else
				MPI_DEBUG_LIBS="libboost_mpi-mt-${MAJOR_PV}-debug$(get_libname)"
			fi

			local lib
			for lib in ${MPI_DEBUG_LIBS}; do
				dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})"
			done
		fi
	fi

	# Create a subdirectory with completely unversioned symlinks
	dodir /usr/$(get_libdir)/boost-${MAJOR_PV}

	local f
	for f in $(ls -1 ${LIBRARY_TARGETS} | grep -v debug); do
		dosym ../${f} /usr/$(get_libdir)/boost-${MAJOR_PV}/${f/-${MAJOR_PV}}
	done

	if use debug; then
		dodir /usr/$(get_libdir)/boost-${MAJOR_PV}-debug
		local f
		for f in $(ls -1 ${LIBRARY_TARGETS} | grep debug); do
			dosym ../${f} /usr/$(get_libdir)/boost-${MAJOR_PV}-debug/${f/-${MAJOR_PV}-debug}
		done
	fi

	popd > /dev/null || die

	if use tools; then
		pushd dist/bin > /dev/null || die
		# Append version postfix to binaries for slotting
		local b
		for b in *; do
			newbin "${b}" "${b}-${MAJOR_PV}"
		done
		popd > /dev/null || die

		pushd dist > /dev/null || die
		insinto /usr/share
		doins -r share/boostbook
		# Append version postfix for slotting
		mv "${D}usr/share/boostbook" "${D}usr/share/boostbook-${MAJOR_PV}" || die
		popd > /dev/null || die
	fi

	pushd status > /dev/null || die
	if [[ -f regress.log ]]; then
		docinto status
		dohtml *.html ../boost.png
		dodoc regress.log
	fi
	popd > /dev/null || die

	# boost's build system truely sucks for not having a destdir.  Because for
	# this reason we are forced to build with a prefix that includes the
	# DESTROOT, dynamic libraries on Darwin end messed up, referencing the
	# DESTROOT instread of the actual EPREFIX.  There is no way out of here
	# but to do it the dirty way of manually setting the right install_names.
	if [[ ${CHOST} == *-darwin* ]]; then
		einfo "Working around completely broken build-system(tm)"
		local d
		for d in "${ED}"usr/lib/*.dylib; do
			if [[ -f ${d} ]]; then
				# fix the "soname"
				ebegin "  correcting install_name of ${d#${ED}}"
				install_name_tool -id "/${d#${D}}" "${d}"
				eend $?
				# fix references to other libs
				refs=$(otool -XL "${d}" | \
					sed -e '1d' -e 's/^\t//' | \
					grep "^libboost_" | \
					cut -f1 -d' ')
				local r
				for r in ${refs}; do
					ebegin "    correcting reference to ${r}"
					install_name_tool -change \
						"${r}" \
						"${EPREFIX}/usr/lib/${r}" \
						"${d}"
					eend $?
				done
			fi
		done
	fi
}

src_test() {
	testing() {
		if use python; then
			local dir
			for dir in ${PYTHON_DIRS}; do
				cp -pr ${dir}-${PYTHON_ABI} ${dir} || die "Copying of '${dir}-${PYTHON_ABI}' to '${dir}' failed"
			done

			if use mpi; then
				cp -p stage/lib/mpi.so-${PYTHON_ABI} "${MPI_PYTHON_MODULE}" || die "Copying of 'stage/lib/mpi.so-${PYTHON_ABI}' to '${MPI_PYTHON_MODULE}' failed"
				cp -p stage/lib/mpi.so-${PYTHON_ABI} stage/lib/mpi.so || die "Copying of 'stage/lib/mpi.so-${PYTHON_ABI}' to 'stage/lib/mpi.so' failed"
			fi
		fi

		pushd tools/regression/build > /dev/null || die
		einfo "Using the following command to build test helpers:"
		einfo "${BJAM} -q -d+2 gentoorelease --user-config=../../../user-config.jam ${OPTIONS} process_jam_log compiler_status"

		${BJAM} -q -d+2 \
			gentoorelease \
			--user-config=../../../user-config.jam \
			${OPTIONS} \
			process_jam_log compiler_status \
			|| die "Building of regression test helpers failed"

		popd > /dev/null || die
		pushd status > /dev/null || die

		# Some of the test-checks seem to rely on regexps
		export LC_ALL="C"

		# The following is largely taken from tools/regression/run_tests.sh,
		# but adapted to our needs.

		# Run the tests & write them into a file for postprocessing
		einfo "Using the following command to test:"
		einfo "${BJAM} --user-config=../user-config.jam ${OPTIONS} --dump-tests"

		${BJAM} \
			--user-config=../user-config.jam \
			${OPTIONS} \
			--dump-tests 2>&1 | tee regress.log || die

		# Postprocessing
		cat regress.log | "$(find ../tools/regression/build/bin/gcc-$(gcc-version)/gentoorelease -name process_jam_log)" --v2
		if test $? != 0; then
			die "Postprocessing the build log failed"
		fi

		cat > comment.html <<- __EOF__
		<p>Tests are run on a <a href="http://www.gentoo.org">Gentoo</a> system.</p>
__EOF__

		# Generate the build log html summary page
		"$(find ../tools/regression/build/bin/gcc-$(gcc-version)/gentoorelease -name compiler_status)" --v2 \
			--comment comment.html "${S}" \
			cs-$(uname).html cs-$(uname)-links.html
		if test $? != 0; then
			die "Generating the build log html summary page failed"
		fi

		# And do some cosmetic fixes :)
		sed -i -e 's|http://www.boost.org/boost.png|boost.png|' *.html || die

		popd > /dev/null || die

		if use python; then
			rm -r ${PYTHON_DIRS} || die
		fi
	}
	if use python; then
		python_execute_function -f -q testing
	else
		testing
	fi
}

pkg_postinst() {
	# mostly copy/paste from eselect-boost

	_boost_tools="bcp bjam compiler_status inspect library_status process_jam_log quickbook wave"

	# ... meaning: <none> and -debug:
	_suffices="|-debug"

	einfo "Removing symlinks from old version"

	local link
	for link in "${ROOT}/usr/include/boost" "${ROOT}/usr/share/boostbook" ; do
		if [[ -L "${link}" ]] ; then
			rm "${link}" || die -q "Couldn't remove \"${link}\" symlink"
		else
			[[ -e "${link}" ]] && die -q "\"${link}\" exists and isn't a symlink"
		fi
	done

	pushd "${ROOT}/usr/lib64" 1>/dev/null
	local lib
	for lib in libboost_*.{a,so} ; do
		[[ -L "${lib}" && "${lib}" != libboost_*[[:digit:]]_[[:digit:]][[:digit:]]@(${_suffices}).@(a|so) ]] || continue
		rm "${lib}" || die -q "Unable to remove \"/usr/lib64/${lib}\" symlink"
	done
	popd 1>/dev/null

	pushd "${ROOT}"/usr/bin 1>/dev/null
	local tool
	for tool in ${_boost_tools} ; do
		[[ -L "${tool}" ]] && ( rm "${tool}" || die -q "Unable to remove \"/usr/bin/${tool}\" symlink" )
	done
	popd 1>/dev/null

	local python_module python_module_dir
	for python_module in mpi.py mpi_debug.py ; do
		for python_module_dir in "${ROOT}"usr/lib64/python*/site-packages ; do
			if [[ -e "${python_module_dir}/${python_module}" ]] ; then
				rm "${python_module_dir}/${python_module}" || die -q "Unable to remove \"${python_module_dir}/${python_module}\""
			fi
		done
	done

	# Deprecated code for older versions of Boost.
	local mod="mpi.so"
	for moddir in "${ROOT}"/usr/lib64/python*/site-packages ; do
		if [ -L "${moddir}/${mod}" ] ; then
			rm "${moddir}/${mod}" || die -q "Unable to remove \"${moddir}/${mod}\" symlink"
		else
			[[ -e "${moddir}/${mod}" ]] && die -q "\"${moddir}/${mod}\" exists and isn't a symlink"
		fi
	done

	if [ -L "${ROOT}/etc/eselect/boost/active" ] ; then
		rm  "${ROOT}/etc/eselect/boost/active" || die -q "Unable to remove \"${ROOT}/etc/eselect/boost/active\" symlink"
	else
		[[ -e "${ROOT}/etc/eselect/boost/active" ]] && die -q "\"${ROOT}/etc/eselect/boost/active\" exists and isn't a symlink"
	fi
}
