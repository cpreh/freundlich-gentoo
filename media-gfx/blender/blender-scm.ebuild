# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
NEEP_PYTHON="3.1"
inherit eutils python subversion versionator

IUSE="+game-engine player +elbeem +openexr ffmpeg jpeg2k openal openmp verse \
	+dds debug doc fftw jack apidoc sndfile lcms tweak-mode sdl collada sse"

LANGS="en ar bg ca cs de el es fi fr hr it ja ko nl pl pt_BR ro ru sr sv uk zh_CN"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org/"
ESVN_REPO_URI="https://svn.blender.org/svnroot/bf-blender/trunk/blender"

#SLOT="$(get_version_component_range 1-2)"
SLOT="2.5"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~amd64 ~x86"

RDEPEND="media-libs/jpeg
	media-libs/libpng
	x11-libs/libXi
	x11-libs/libX11
	sys-libs/zlib
	media-libs/tiff
	media-libs/libsamplerate
	virtual/opengl
	>=media-libs/freetype-2.0
	virtual/libintl
	virtual/libiconv
	media-libs/glew
	dev-cpp/eigen:2
	sdl? ( media-libs/libsdl[audio,joystick] )
	openexr? ( media-libs/openexr )
	ffmpeg? (
		>=media-video/ffmpeg-0.5[x264,xvid,mp3,encode,theora]
		jpeg2k? ( >=media-video/ffmpeg-0.5[x264,xvid,mp3,encode,theora,jpeg2k] )
	)
	openal? ( >=media-libs/openal-1.6.372 )
	fftw? ( sci-libs/fftw:3.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	sndfile? ( media-libs/libsndfile )
	lcms? ( media-libs/lcms )
	collada? (
		dev-libs/libpcre
		dev-libs/expat
	)"

DEPEND=">=sys-devel/gcc-4.3.2[openmp?]
	apidoc? (
		dev-python/epydoc
		>=app-doc/doxygen-1.5.7[-nodot]
	)
	dev-util/scons
	x11-base/xorg-server
	${RDEPEND}"

S="${WORKDIR}/${PN}"

blend_with() {
	local UWORD="$2"
	[ -z "${UWORD}" ] && UWORD="$1"
	if useq $1; then
		echo "WITH_BF_${UWORD}=1" | tr '[:lower:]' '[:upper:]' \
			>> "${S}"/user-config.py
	else
		echo "WITH_BF_${UWORD}=0" | tr '[:lower:]' '[:upper:]' \
			>> "${S}"/user-config.py
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-desktop.patch
	epatch "${FILESDIR}"/${PN}-${SLOT}-doxygen.patch

	# OpenJPEG
	einfo "Removing bundled OpenJPEG ..."
	rm -r extern/libopenjpeg

	# FFmpeg
	einfo "Removing bundled FFmpeg ..."
	rm -r extern/ffmpeg

	einfo "Removing bundled Glew ..."
	rm -r extern/glew
	epatch "${FILESDIR}"/${PN}-${SLOT}-glew.patch

	einfo "Removing bundled LAME ..."
	rm -r extern/libmp3lame

	einfo "Removing bundled x264 ..."
	rm -r extern/x264

	einfo "Removing bundled Xvid ..."
	rm -r extern/xvidcore

	#einfo "Removing bundled LZMA ..."
	#rm -r extern/lzma

	#einfo "Removing bundled binreloc ..."
	#rm -r extern/binreloc

	einfo "Removing bundled Eigen2 ..."
	rm -r extern/Eigen2
	epatch "${FILESDIR}"/${PN}-${SLOT}-eigen.patch
}

src_configure() {
	# add ffmpeg info to the Scons build options
	# and configure ogg vorbis/theora support for ffmpeg
	if use ffmpeg; then
		cat <<- EOF >> "${S}"/user-config.py
			BF_FFMPEG="/usr"
			BF_FFMPEG_LIB="avformat avcodec swscale avutil avdevice"
			WITH_BF_OGG=1
		EOF
	fi

	# add system openjpeg into Scons build options.
	cat <<- EOF >> "${S}"/user-config.py
		BF_OPENJPEG="/usr"
		BF_OPENJPEG_INC="/usr/include"
		BF_OPENJPEG_LIB="openjpeg"
	EOF

	# configure internationalization only if LINGUAS have more
	# languages than 'en', otherwise must be disabled
	if [[ -z ${LINGUAS} ]] || [[ ${LINGUAS} == "en" ]]; then
		cat <<- EOF >> "${S}"/user-config.py
			WITH_BF_INTERNATIONAL=0
		EOF
	fi

	# configure Elbeem fluid system
	if ! use elbeem; then
		cat <<- EOF >> "${S}"/user-config.py
			BF_NO_ELBEEM=1
		EOF
	fi

	# configure Tweak Mode
	if use tweak-mode; then
		cat <<- EOF >> "${S}"/user-config.py
			BF_TWEAK_MODE=1
		EOF
	fi

	# FIX: Game Engine module needs to be active to build the Blender Player
	if ! use game-engine && use player; then
		elog "Forcing Game Engine [+game-engine] as required by Blender Player [+player]"
		cat <<- EOF >> "${S}"/user-config.py
			WITH_BF_GAMEENGINE=1
		EOF
	else
		blend_with game-engine gameengine
	fi

	# set CFLAGS used in /etc/make.conf correctly
	echo "CFLAGS= [`for i in ${CFLAGS[@]}; do printf "%s \'$i"\',; done`] " \
		| sed -e "s:,]: ]:" >> "${S}"/user-config.py

	# set CXXFLAGS used in /etc/make.conf correctly
	echo "CXXFLAGS= [`for i in ${CXXFLAGS[@]}; do printf "%s \'$i"\',; done`]" \
		| sed -e "s:,]: ]:" >> "${S}"/user-config.py
	echo "CCFLAGS= [`for i in ${CXXFLAGS[@]}; do printf "%s \'$i"\',; done`]" \
		| sed -e "s:,]: ]:" >> "${S}"/user-config.py
	# FIX: linux2-config.py lacks a BGE_CXXFLAGS
	echo "BGE_CXXFLAGS= [`for i in ${CXXFLAGS[@]}; do printf "%s \'$i"\',; done`]" \
		| sed -e "s:,]: ]:" >> "${S}"/user-config.py

	# set LDFLAGS used in /etc/make.conf correctly
	echo "LINKFLAGS= [`for i in ${LDFLAGS[@]}; do printf "%s \'$i"\',; done`]" \
		| sed -e "s:,]: ]:" >> "${S}"/user-config.py

	# reset warning flags (useless for NON blender developers)
	echo "C_WARN=['']"   >> "${S}"/user-config.py
	echo "CC_WARN=['']"  >> "${S}"/user-config.py
	echo "CXX_WARN=['']" >> "${S}"/user-config.py

	# detecting -j value from MAKEOPTS
	local NUMJOBS="$( echo "${MAKEOPTS}" | sed -ne 's,.*-j\([[:digit:]]\+\).*,\1,p' )"
	[[ -z "${NUMJOBS}" ]] && NUMJOBS=1

	# generic settings which differ from the defaults from linux2-config.py
	cat <<- EOF >> "${S}"/user-config.py
		BF_INSTALLDIR="../install"
		WITHOUT_BF_PYTHON_INSTALL=1
		BF_BUILDINFO=1
		BF_QUIET=1
		BF_NUMJOBS=${NUMJOBS}
		WITH_BF_FHS=1
		WITH_BF_BINRELOC=0
	EOF

	# configure WITH_BF* Scons build options
	for arg in \
		'sdl' \
		'apidoc docs' \
		'lcms' \
		'jack' \
		'sndfile' \
		'openexr' \
		'dds' \
		'fftw fftw3' \
		'jpeg2k openjpeg' \
		'openal'\
		'ffmpeg' \
		'player' \
		'openmp' \
		'collada' \
		'sse rayoptimization' \
		'verse' ; do
		blend_with ${arg}
	done
}

src_compile() {
	scons || die \
		'!!! Please add "${S}/scons.config" when filing bugs reports \
		to bugs.gentoo.org'

	einfo "Building plugins ..."
	cd "${WORKDIR}"/install/share/blender/${SLOT}/plugins/ \
		|| die "dir ${WORKDIR}/install/share/blender/${SLOT}/plugins/ do not exists"
	chmod 755 bmake
	emake  > /dev/null || die
}

src_install() {
	# creating binary wrapper
	cat <<- EOF >> "${WORKDIR}/install/bin/blender-${SLOT}"
		#!/bin/sh

		# stop this script if the local blender path is a symlink
		if [ -L \${HOME}/.blender ]; then
			echo "Detected a symbolic link for \${HOME}/.blender"
			echo "Sorry, to avoid dangerous situations, the Blender binary can"
			echo "not be started until you have removed the symbolic link:"
			echo "  # rm -i \${HOME}/.blender"
			exit 1
		fi

		BLENDERPATH="/usr/share/blender/${SLOT}" exec /usr/bin/blender-bin-${SLOT} "\$@"
	EOF

	# install binaries
	exeinto /usr/bin/
	mv "${WORKDIR}/install/bin/blender" "${WORKDIR}/install/bin/blender-bin-${SLOT}"
	doexe "${WORKDIR}/install/bin/blender-bin-${SLOT}"
	doexe "${WORKDIR}/install/bin/blender-${SLOT}"
	use player && doexe "${WORKDIR}"/install/bin/blenderplayer
	use verse && doexe "${WORKDIR}"/install/bin/verse_server

	# install plugins
	exeinto /usr/share/${PN}/${SLOT}/textures
	doexe "${WORKDIR}"/install/share/blender/${SLOT}/plugins/texture/*.so
	exeinto /usr/share/${PN}/${SLOT}/sequences
	doexe "${WORKDIR}"/install/share/blender/${SLOT}/plugins/sequence/*.so
	insinto /usr/include/${PN}/${SLOT}
	doins "${WORKDIR}"/install/share/blender/${SLOT}/plugins/include/*.h
	rm -r "${WORKDIR}"/install/share/blender/${SLOT}/plugins

	# install I18N
	if [[ ${LINGUAS} != "en" && -n ${LINGUAS} ]]; then

		rm "${WORKDIR}"/install/share/blender/${SLOT}/.Blanguages \
			|| die "file .Blanguages do not exists"
		echo "English:en_US" > "${WORKDIR}"/install/share/blender/${SLOT}/.Blanguages

		insinto /usr/share/${PN}/${SLOT}/locale
		for LANG in ${LINGUAS}; do
			[[ ${LANG} == "en" ]] && continue

			# installing locale
			doins -r "${WORKDIR}/install/share/blender/${SLOT}/locale/${LANG}" || die "failed '${LANG}' locale installation"

			# populating file .Blanguages with only the locales choiced by the
			# user through LINGUAS
			local I18N
			case "${LANG}" in
			ja)
				I18N="Japanese:ja_JP"
				;;
			nl)
				I18N="Dutch:nl_NL"
				;;
			it)
				I18N="Italian:it_IT"
				;;
			de)
				I18N="German:de_DE"
				;;
			fi)
				I18N="Finnish:fi_FI"
				;;
			sv)
				I18N="Swedish:sv_SE"
				;;
			fr)
				I18N="French:fr_FR"
				;;
			es)
				I18n="Spanish:es_ES"
				;;
			ca)
				I18N="Catalan:ca_ES"
				;;
			cs)
				I18N="Czech:cs_CZ"
				;;
			pt_BR)
				I18N="Brazilian Portuguese:pt_BR"
				;;
			zh_CN)
				I18N="Simplified Chinese:zh_CN"
				;;
			ru)
				I18N="Russian:ru_RU"
				;;
			hr)
				I18N="Croatian:hr_HR"
				;;
			sr)
				I18N="Serbian:sr"
				;;
			uk)
				I18N="Ukrainian:uk_UA"
				;;
			pl)
				I18N="Polish:pl_PL"
				;;
			ro)
				I18N="Romanian:ro"
				;;
			ar)
				I18N="Arabic:ar"
				;;
			bg)
				I18N="Bulgarian:bg"
				;;
			el)
				I18N="Greek:el"
				;;
			ko)
				I18N="Korean:ko"
				;;
			esac
			echo "${I18N}" >> "${WORKDIR}"/install/share/blender/${SLOT}/.Blanguages
	    done
	fi

	# install desktop file
	insinto /usr/share/pixmaps
	cp release/freedesktop/icons/scalable/blender.svg \
		release/freedesktop/icons/scalable/blender-${SLOT}.svg
	doins release/freedesktop/icons/scalable/blender-${SLOT}.svg
	insinto /usr/share/applications
	cp release/freedesktop/blender.desktop \
		release/freedesktop/blender-${SLOT}.desktop
	doins release/freedesktop/blender-${SLOT}.desktop

	# install docs
	dodoc README
	use doc && dodoc release/text/BlenderQuickStart.pdf
	if use apidoc; then

		einfo "Generating (BGE) Blender Game Engine API docs ..."
		docinto "API/BGE_API"
		dohtml -r "${WORKDIR}"/install/share/${PN}/${SLOT}/doc/*
		rm -r "${WORKDIR}"/install/share/${PN}/${SLOT}/doc

#		einfo "Generating (BPY) Blender Python API docs ..."
#		epydoc source/blender/python/doc/*.py -v \
#			-o doc/BPY_API \
#			--quiet --quiet --quiet \
#			--simple-term \
#			--inheritance=included \
#			--graph=all \
#			--dotpath /usr/bin/dot \
#			|| die "epydoc failed."
#		docinto "API/python"
#		dohtml -r doc/BPY_API/*

		einfo "Generating Blender C/C++ API docs ..."
		pushd "${S}"/doc > /dev/null
			doxygen -u Doxyfile
			doxygen || die "doxygen failed to build API docs."
			docinto "API/blender"
			dohtml -r html/*
		popd > /dev/null
	fi

	# final cleanup
	rm -r "${WORKDIR}"/install/share/blender/${SLOT}/{Python-license.txt,icons,GPL-license.txt,copyright.txt,BlenderQuickStart.pdf,blender.html,release_249.txt}

	# installing blender
	insinto /usr/share/${PN}/${SLOT}
	doins -r "${WORKDIR}"/install/share/blender/${SLOT}/*
	doins release/VERSION

	# FIX: making all python scripts readable only by group 'users',
	#      so nobody can modify scripts apart root user, but users
	#      can write their python cache (*.pyc).
	chown root:users -R "${D}/usr/share/${PN}/${SLOT}/scripts"
	chmod 750 -R "${D}/usr/share/${PN}/${SLOT}/scripts"

}

pkg_preinst() {
	if [ -h "${ROOT}/usr/$(get_libdir)/blender/plugins/include" ];
	then
		rm -r "${ROOT}"/usr/$(get_libdir)/blender/plugins/include
	fi
}

pkg_postinst() {
	echo
	elog "Blender uses python integration. As such, may have some"
	elog "inherit risks with running unknown python scripting."
	elog
	elog "CVE-2008-1103-1.patch has been removed as it interferes"
	elog "with autosave undo features. Up stream blender coders"
	elog "have not addressed the CVE issue as the status is still"
	elog "a CANDIDATE and not CONFIRMED."
	elog
	elog "CVE-2008-4863.patch has been remove as it interferes"
	elog "with the load of bpy_ops.py and all the UI python"
	elog "scripts."
	elog
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to /home/user/tmp or another tmp file under your"
	elog "home directory. This can be done by starting blender, then"
	elog "dragging the main menu down do display all paths."
	elog
	elog "Blender has its own internal rendering engine but you"
	elog "can export to external renderers for image computation"
	elog "like: YafRay[1], sunflow[2], PovRay[3] and luxrender[4]"
	elog
	elog "If you need one of them just emerge it:"
	elog "  [1] emerge -av media-gfx/yafray"
	elog "  [2] emerge -av media-gfx/sunflow"
	elog "  [3] emerge -av media-gfx/povray"
	elog "  [4] emerge -av media-gfx/luxrender"
	elog
	elog "When setting the Blender paths with the User Preferences"
	elog "dialog box, remember to NOT declare your home's paths as:"
	elog "~/.blender, but as: /home/user/.blender; in other words,"
	elog "DO NOT USE the tilde inside the paths, as Blender is not"
	elog "able to handle it, ignoring your customizations."
}
