# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
NEED_PYTHON="3.1"
inherit flag-o-matic subversion eutils python cmake-utils

IUSE="+game-engine player +elbeem +openexr ffmpeg jpeg2k +openal web openmp verse \
	+dds debug doc fftw jack guardedalloc apidoc sndfile"

LANGS="en ar bg ca cs de el es fi fr hr it ja ko nl pl pt_BR ro ru sr sv uk zh_CN"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org/"
ESVN_REPO_URI="https://svn.blender.org/svnroot/bf-blender/trunk/blender"

SLOT="0"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~amd64 ~x86"

# NOTES:
# - cmake 2.6.4-r2 is required to correctly detect python 3.1;
RDEPEND="media-libs/jpeg
	media-libs/libpng
	>=media-libs/libsdl-1.2
	x11-libs/libXi
	x11-libs/libX11
	sys-libs/zlib
	media-libs/tiff
	media-libs/libsamplerate
	virtual/opengl
	>=media-libs/freetype-2.0
	virtual/libintl
	virtual/libiconv
	game-engine? ( >=media-libs/libsdl-1.2[audio,joystick] )
	openexr? ( media-libs/openexr )
	ffmpeg? (
		>=media-video/ffmpeg-0.5[x264,xvid,mp3,encode,theora]
		jpeg2k? ( >=media-video/ffmpeg-0.5[x264,xvid,mp3,encode,theora,jpeg2k] )
	)
	openal? ( >=media-libs/openal-1.6.372 )
	web? ( >=net-libs/xulrunner-1.9.0.10:1.9 )
	fftw? ( sci-libs/fftw:3.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	sndfile? ( media-libs/libsndfile )"

DEPEND=">=sys-devel/gcc-4.3.2[openmp?]
	>=dev-util/cmake-2.6.4-r3[python3]
	apidoc? (
		dev-python/epydoc
		>=app-doc/doxygen-1.5.7[-nodot]
	)
	x11-base/xorg-server
	${RDEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	#epatch "${FILESDIR}"/${PN}-2.5-CVE-2008-1103.patch
	epatch "${FILESDIR}"/${PN}-2.5-CVE-2008-4863.patch
	#epatch "${FILESDIR}"/${PN}-2.49a-sys-openjpeg.patch
	epatch "${FILESDIR}"/${PN}-desktop.patch
	epatch "${FILESDIR}"/${PN}-2.5-doxygen.patch
	#epatch "${FILESDIR}"/${PN}-2.5-optimizations.patch
	#epatch "${FILESDIR}"/${PN}-2.5-optimizations2.patch
	#epatch "${FILESDIR}"/${PN}-2.5-optimizations3.patch
	#epatch "${FILESDIR}"/${PN}-2.5-editparticle.patch
	epatch "${FILESDIR}"/${PN}-2.5-cmake.patch
	epatch "${FILESDIR}"/${PN}-2.5-cmake-without-extern.patch

	# OpenJPEG
	#epatch "${FILESDIR}"/${PN}-2.5-FindOpenJPEG.cmake.patch
	epatch "${FILESDIR}"/${PN}-2.5-cmake-imbuf-openjpeg.patch
	einfo "Removing bundled OpenJPEG ..."
	rm -r extern/libopenjpeg

	# FFmpeg
	einfo "Removing bundled FFmpeg ..."
	rm -r extern/ffmpeg

	# Bullet Phisyc SDK
	#epatch "${FILESDIR}"/${PN}-2.5-FindBullet.cmake.patch
	#epatch "${FILESDIR}"/${PN}-2.5-cmake-blenkernel.patch
	#epatch "${FILESDIR}"/${PN}-2.5-cmake-gameengine-converter.patch
	#epatch "${FILESDIR}"/${PN}-2.5-cmake-gameengine-blenderroutines.patch
	#epatch "${FILESDIR}"/${PN}-2.5-cmake-gameengine-ketsji.patch
	#epatch "${FILESDIR}"/${PN}-2.5-cmake-gameengine-physics.patch
	#epatch "${FILESDIR}"/${PN}-2.5-cmake-smoke.patch
	#einfo "Removing bundled Bullet2 ..."
	#rm -r extern/bullet2

	#einfo "Removing bundled Glew ..."
	#rm -r extern/glew

	einfo "Removing bundled LAME ..."
	rm -r extern/libmp3lame

	einfo "Removing bundled x264 ..."
	rm -r extern/x264

	einfo "Removing bundled Xvid ..."
	rm -r extern/xvidcore

	#einfo "Removing bundled LZMA ..."
	#rm -r extern/lzma

	#einfo "Removing bundled LZO ..."
	#rm -r extern/lzo

	#einfo "Removing binreloc ..."
	#rm -r extern/binreloc
}

src_configure() {
	use debug && mycmakeargs="${mycmakeargs} -DCMAKE_VERBOSE_MAKEFILE=ON"

	# FIX: internationalization support is enabled
	# only is there are other linguas than 'en'
	if [[ "${LINGUAS}" == "en" ]]; then
		mycmakeargs="${mycmakeargs} -DWITH_INTERNATIONAL=OFF"
	else
		mycmakeargs="${mycmakeargs} -DWITH_INTERNATIONAL=ON"
	fi

	# FIX: Game Engine module needs to be active to build the Blender Player
	if ! use game-engine && use player; then
		elog "Forcing Game Engine [+game-engine] as required by Blender Player [+player]"
		mycmakeargs="${mycmakeargs} -DWITH_GAMEENGINE=ON"
	else
		mycmakeargs="${mycmakeargs} \
			$(cmake-utils_use_with game-engine GAMEENGINE)"
	fi

	# FIX: Physic Engine module needs to be active to build Game Engine
#	if ! use physic && use game-engine; then
#		elog "Forcing Physic Engine [+physic] as required by Game Engine [+game-engine]"
#		mycmakeargs="${mycmakeargs} -DWITH_BULLET=ON"
#	else
#		mycmakeargs="${mycmakeargs} \
#			$(cmake-utils_use_with physic BULLET)"
#	fi

	PYVER=3.1
	mycmakeargs="${mycmakeargs} \
		-DWITH_BULLET=ON \
		$(cmake-utils_use_with elbeem ELBEEM) \
		-DWITH_QUICKTIME=OFF \
		$(cmake-utils_use_with openexr OPENEXR) \
		$(cmake-utils_use_with dds DDS) \
		$(cmake-utils_use_with ffmpeg FFMPEG) \
		-DWITH_PYTHON=ON \
		-DWITH_SDL=ON \
		$(cmake-utils_use_with jpeg2k OPENJPEG) \
		$(cmake-utils_use_with openal OPENAL) \
		$(cmake-utils_use_with openmp OPENMP) \
		$(cmake-utils_use_with web WEBPLUGIN) \
		$(cmake-utils_use_with fftw FFTW3) \
		$(cmake-utils_use_with jack JACK) \
		$(cmake-utils_use_with sndfile SNDFILE) \
		$(cmake-utils_use_with guardedalloc CXX_GUARDEDALLOC) \
		$(cmake-utils_use_with player PLAYER) \
		-DWITH_INSTALL=ON \
		-DWITH_BUILDINFO=ON"

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	# FIX: plugins are not compiled by CMake
	einfo "Building plugins ..."
	cp -r release/plugins/ "${CMAKE_BUILD_DIR}"/bin || die
	mkdir -p "${CMAKE_BUILD_DIR}"/bin/plugins/include || die
	cp source/blender/blenpluginapi/*.h "${CMAKE_BUILD_DIR}"/bin/plugins/include || die
	chmod 755 "${CMAKE_BUILD_DIR}"/bin/plugins/bmake || die
	cd "${CMAKE_BUILD_DIR}"/bin/plugins || die
	make > /dev/null || die "texture/sequence compilation failed."
}

# NOTE: blender lacks a CMake install target
src_install() {
	# install binaries
	exeinto /usr/bin/
	mv "${CMAKE_BUILD_DIR}"/bin/blender "${CMAKE_BUILD_DIR}"/bin/blender-bin
	doexe "${CMAKE_BUILD_DIR}"/bin/blender-bin
	doexe "${FILESDIR}"/blender
	use player && doexe "${CMAKE_BUILD_DIR}"/bin/blenderplayer
	use verse && doexe "${CMAKE_BUILD_DIR}"/bin/verse_server

	# install plugins
	exeinto /usr/$(get_libdir)/${PN}/textures
	doexe "${CMAKE_BUILD_DIR}"/bin/plugins/texture/*.so
	exeinto /usr/$(get_libdir)/${PN}/sequences
	doexe "${CMAKE_BUILD_DIR}"/bin/plugins/sequence/*.so
	insinto /usr/include/${PN}
	doins "${CMAKE_BUILD_DIR}"/bin/plugins/include/*.h

	# install I18N
	if [[ ${LINGUAS} != "en" && -n ${LINGUAS} ]]; then

		rm "${CMAKE_BUILD_DIR}"/bin/.blender/.Blanguages \
			|| die "file .Blanguages do not exists"
		echo "English:en_US" > "${CMAKE_BUILD_DIR}"/bin/.blender/.Blanguages

		insinto /usr/share/locale
		for LANG in ${LINGUAS}; do
			[[ ${LANG} == "en" ]] && continue

			# installing locale
			doins -r "${CMAKE_BUILD_DIR}/bin/.blender/locale/${LANG}" || die "failed '${LANG}' locale installation"

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
			zh_CN)I18N="Simplified Chinese:zh_CN"
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
			echo "${I18N}" >> "${CMAKE_BUILD_DIR}"/bin/.blender/.Blanguages
	    done

		# install .Blanguages
		insinto /usr/share/${PN}
		doins "${CMAKE_BUILD_DIR}"/bin/.blender/.Blanguages
	fi

	# install fonts
	doins "${CMAKE_BUILD_DIR}"/bin/.blender/.bfont.ttf
	doins release/VERSION

	# install scripts
	insinto /usr/share/${PN}
	doins -r release/scripts
	doins -r "${CMAKE_BUILD_DIR}"/bin/.blender/io
	doins -r "${CMAKE_BUILD_DIR}"/bin/.blender/ui

	# FIX: making all python scripts readable only by group 'users'
	#      (nobody can modify scripts apart root user)
	chown root:users -R "${D}/usr/share/${PN}/scripts"
	chmod -R 750 "${D}/usr/share/${PN}/scripts"
	# FIX: bpydata/ and bpymodules/ dirs must have write perms for group 'users'
	chmod 770 "${D}/usr/share/${PN}/scripts/bpydata"
	chmod 770 "${D}/usr/share/${PN}/scripts/bpydata/config"
	chmod 770 "${D}/usr/share/${PN}/scripts/bpymodules"

	# install desktop file
	insinto /usr/share/pixmaps
	doins release/freedesktop/icons/scalable/blender.svg
	insinto /usr/share/applications
	doins release/freedesktop/blender.desktop

	# install docs
	dodoc README
	use doc && dodoc release/text/BlenderQuickStart.pdf
	if use apidoc; then
		einfo "Removing bundled python ..."
		#rm -r "${CMAKE_BUILD_DIR}"/bin/.blender/python
		#python -c \
		#	source/blender/python/epy_doc_gen.py \
		#	|| die "epy_doc_gen.py failed."
		epydoc source/blender/python/doc/*.py -v \
			-o doc/BPY_API \
			--quiet --quiet --quiet \
			--simple-term \
			--inheritance=included \
			--graph=all \
			--dotpath /usr/bin/dot \
			|| die "epydoc failed."

		einfo "Generating Blender C/C++ API docs ..."
		pushd "${S}"/doc > /dev/null
			doxygen -u Doxyfile
			doxygen || die "doxygen failed to build API docs."
			docinto "API/blender"
			dohtml -r html/*
		popd > /dev/null
	fi
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
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to ~tmp or another tmp file under your home"
	elog "directory. This can be done by starting blender, then"
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
