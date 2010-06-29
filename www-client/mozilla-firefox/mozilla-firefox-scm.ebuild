# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib pax-utils fdo-mime autotools java-pkg-opt-2 mercurial

DESKTOP_PV="3.7pre"
EHG_REPO_URI="http://hg.mozilla.org/mozilla-central"

DESCRIPTION="Firefox Web Browser"
HOMEPAGE="http://www.mozilla.com/firefox"

KEYWORDS=""
SLOT="0"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"

IUSE_INTERNAL="+pgo internal_cairo +internal_lcms +internal_nspr +internal_nss +internal_sqlite"
IUSE="${IUSE_INTERNAL} +alsa bindist ipc java +safebrowsing spell libnotify wifi webm"

RDEPEND=">=sys-devel/binutils-2.16.1
	x11-libs/pango[X]
	alsa? ( media-libs/alsa-lib )
	spell? ( >=app-text/hunspell-1.2 )
	libnotify? ( x11-libs/libnotify )
	wifi? ( net-wireless/wireless-tools )
	!internal_cairo? ( >=x11-libs/cairo-1.8.8[X] )
	!internal_lcms? ( >=media-libs/lcms-1.18 )
	!internal_nss? ( >=dev-libs/nss-3.12.4 )
	!internal_nspr? ( >=dev-libs/nspr-4.8 )
	!internal_sqlite? ( >=dev-db/sqlite-3.6.22-r2[fts3,secure-delete,unlock-notify] )
	!!www-client/${PN}-bin"

DEPEND="${RDEPEND}
	java? ( >=virtual/jdk-1.4 )
	dev-util/pkgconfig"

RDEPEND="${RDEPEND} java? ( >=virtual/jre-1.4 )"

S="${WORKDIR}/mozilla-central"

QA_PRESTRIPPED="usr/$(get_libdir)/${PN}/firefox"

pkg_setup() {
	# Ensure we always build with C locale.
	export LANG="C"
	export LC_ALL="C"
	export LC_MESSAGES="C"
	export LC_CTYPE="C" 

	if ! use bindist; then
		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with Mozilla Foundation"
		elog "You can disable it by emerging ${PN} _with_ the bindist USE-flag"
		echo ""
	fi

	if ! use internal_nss && ! use internal_nspr; then
		elog "You have disabled internal_nss and internal_nspr USE-flags,"
		elog "if you have not set this on puropse, note that USE=\"-*\" in your"
		elog "make.conf/use.conf is evil and removes all IUSE defaults. Get rid of it!"
		echo ""
	fi

	java-pkg-opt-2_pkg_setup
}

src_prepare() {
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${FILESDIR}"/patches

	# Allow user to apply additional patches without modifing ebuild
	epatch_user

	eautoreconf

	cd js/src
	eautoreconf
}

src_configure() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"
	MEXTENSIONS="default"

	mozconfig_init
	mozconfig_config

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	# --as-needed breaks us
	filter-ldflags "-Wl,--as-needed" "--as-needed"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate 'broken' --disable-crashreporter
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places

	 # System-wide install specs
	mozconfig_annotate '' --disable-installer
	mozconfig_annotate '' --disable-updater
	mozconfig_annotate '' --disable-strip
	mozconfig_annotate '' --disable-install-strip

	# Use flags for internal parts
	if ! use internal_sqlite; then
		mozconfig_annotate '' --enable-system-sqlite
	else
		mozconfig_annotate '' --disable-system-sqlite
	fi

	if ! use internal_nspr; then
		mozconfig_annotate '' --with-system-nspr
	else
		mozconfig_annotate '' --without-system-nspr
	fi

	if ! use internal_nss; then
		mozconfig_annotate '' --with-system-nss
	else
		mozconfig_annotate '' --without-system-nss
	fi

	if ! use internal_lcms; then
		mozconfig_annotate '' --enable-system-lcms
	else
		mozconfig_annotate '' --disable-system-lcms
	fi

	if ! use internal_cairo; then
		mozconfig_annotate '' --enable-system-cairo
	else
		mozconfig_annotate '' --disable-system-cairo
	fi

	# General use flags
	mozconfig_use_enable ipc # +ipc, upstream default
	mozconfig_use_enable libnotify
	mozconfig_use_enable java javaxpcom
	mozconfig_use_enable wifi necko-wifi
	mozconfig_use_enable pgo profile-guided-optimization
	mozconfig_use_enable spell system-hunspell
	mozconfig_use_enable safebrowsing safe-browsing
	mozconfig_use_enable alsa ogg
	mozconfig_use_enable webm webm
	mozconfig_use_enable alsa wave
	mozconfig_use_enable !bindist official-branding

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	econf || die "econf failed"
}

src_compile() {
	[ "${DO_NOT_WANT_MP}" = "true" ] && jobs=-j1 || jobs=${MAKEOPTS}
	emake ${jobs} || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	cp "${FILESDIR}"/gentoo-default-prefs.js "${D}"${MOZILLA_FIVE_HOME}/defaults/pref/all-gentoo.js

	# Install icon and .desktop for menu entry
	if ! use bindist; then
		newicon "${S}"/other-licenses/branding/${PN}/content/icon48.png ${PN}-icon.png
		newmenu "${FILESDIR}"/icon/${PN}.desktop \
			${PN}-${DESKTOP_PV}.desktop
	else
		newicon "${S}"/browser/branding/unofficial/icon48.png ${PN}-icon-unbranded.png
		newmenu "${FILESDIR}"/icon/${PN}-unbranded.desktop \
			${PN}-${DESKTOP_PV}.desktop
	fi

	# Add StartupNotify=true bug 237317
	if use startup-notification; then
		echo "StartupNotify=true" >> "${D}"/usr/share/applications/${PN}-${DESKTOP_PV}.desktop
	fi

	pax-mark m "${D}"/${MOZILLA_FIVE_HOME}/firefox

	# Plugins dir
	dosym ../nsbrowser/plugins "${MOZILLA_FIVE_HOME}"/plugins \
	|| die "failed to symlink"

	echo "MOZ_PLUGIN_PATH=/usr/$(get_libdir)/nsbrowser/plugins" > 66${PN}
	doenvd 66${PN}

	# very ugly hack to make firefox not sigbus on sparc
	if use sparc ; then
		sed -i \
				-e 's/Firefox/FirefoxGentoo/g' \
				"${D}/${MOZILLA_FIVE_HOME}/application.ini" \
				|| die "sparc sed failed"
	fi
}

pkg_postinst() {
	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update

	echo
	elog "If you should experience parallel build issues, please"
	elog "export DO_NOT_WANT_MP=true and try again before posting in our"
	elog "forums.gentoo.org support thread (the URL is shown below)."
	echo
	elog "DO NOT report bugs to Gentoo's bugzilla"
	elog "See https://forums.gentoo.org/viewtopic-t-732395.html for support topic on Gentoo forums."
	echo
}
