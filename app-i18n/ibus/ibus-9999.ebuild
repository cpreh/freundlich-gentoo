# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/ibus/ibus-1.3.99.20110817.ebuild,v 1.2 2011/09/05 08:38:15 naota Exp $

EAPI="3"
PYTHON_DEPEND="python? 2:2.5"
inherit confutils eutils git gnome2-utils multilib python

DESCRIPTION="Intelligent Input Bus for Linux / Unix OS"
HOMEPAGE="http://code.google.com/p/ibus/"
EGIT_REPO_URI="git://github.com/ibus/ibus.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="doc +gconf gtk gtk3 introspection nls +python vala X"

RDEPEND=">=dev-libs/glib-2.26:2
	gconf? ( >=gnome-base/gconf-2.12:2 )
	gnome-base/librsvg:2
	sys-apps/dbus
	app-text/iso-codes
	gtk? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
	X? (
		sys-apps/dbus[X]
		x11-libs/libX11
		x11-libs/gtk+:2
	)
	introspection? ( >=dev-libs/gobject-introspection-0.6.8 )
	python? (
		dev-python/notify-python
		>=dev-python/dbus-python-0.83
	)
	nls? ( virtual/libintl )"
#	X? ( x11-libs/libX11 )
#	gtk? ( x11-libs/gtk+:2 x11-libs/gtk+:3 )
#	vala? ( dev-lang/vala )
DEPEND="${RDEPEND}
	>=dev-lang/perl-5.8.1
	dev-perl/XML-Parser
	dev-util/gtk-doc
	dev-util/pkgconfig
	gnome-base/gnome-common
	doc? ( >=dev-util/gtk-doc-1.9 )
	nls? ( >=sys-devel/gettext-0.16.1 )"
RDEPEND="${RDEPEND}
	python? (
		dev-python/pygtk
		dev-python/pyxdg
	)"

RESTRICT="test"

update_gtk_immodules() {
	local GTK2_CONFDIR="/etc/gtk-2.0"
	# bug #366889
	if has_version '>=x11-libs/gtk+-2.22.1-r1:2' || has_multilib_profile ; then
		GTK2_CONFDIR="${GTK2_CONFDIR}/$(get_abi_CHOST)"
	fi
	mkdir -p "${EPREFIX}${GTK2_CONFDIR}"

	if [ -x "${EPREFIX}/usr/bin/gtk-query-immodules-2.0" ] ; then
		"${EPREFIX}/usr/bin/gtk-query-immodules-2.0" > "${EPREFIX}${GTK2_CONFDIR}/gtk.immodules"
	fi
}

update_gtk3_immodules() {
	if [ -x "${EPREFIX}/usr/bin/gtk-query-immodules-3.0" ] ; then
		"${EPREFIX}/usr/bin/gtk-query-immodules-3.0" --update-cache
	fi
}

pkg_setup() {
	# bug #342903
	confutils_require_any X gtk gtk3
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_unpack() {
	git_src_unpack || die
}

src_configure() {
	./autogen.sh || die

	econf \
		$(use_enable doc gtk-doc) \
		$(use_enable doc gtk-doc-html) \
		$(use_enable introspection) \
		$(use_enable gconf) \
		$(use_enable gtk gtk2) \
		$(use_enable gtk xim) \
		$(use_enable gtk3) \
		$(use_enable nls) \
		$(use_enable python) \
		$(use_enable vala) \
		$(use_enable X xim) || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	find "${ED}" -name '*.la' -type f -delete || die

	insinto /etc/X11/xinit/xinput.d
	newins xinput-ibus ibus.conf || die

	# bug 289547
	keepdir /usr/share/ibus/{engine,icons} || die

	dodoc AUTHORS ChangeLog NEWS README || die
}

pkg_preinst() {
	use gconf && gnome2_gconf_savelist
	gnome2_icon_savelist
}

pkg_postinst() {
	use gconf && gnome2_gconf_install
	use gtk && update_gtk_immodules
	use gtk3 && update_gtk3_immodules
	use python && python_mod_optimize /usr/share/${PN}
	gnome2_icon_cache_update

	elog "To use ibus, you should:"
	elog "1. Get input engines from sunrise overlay."
	elog "   Run \"emerge -s ibus-\" in your favorite terminal"
	elog "   for a list of packages we already have."
	elog
	elog "2. Setup ibus:"
	elog
	elog "   $ ibus-setup"
	elog
	elog "3. Set the following in your user startup scripts"
	elog "   such as .xinitrc, .xsession or .xprofile:"
	elog
	elog "   export XMODIFIERS=\"@im=ibus\""
	elog "   export GTK_IM_MODULE=\"ibus\""
	elog "   export QT_IM_MODULE=\"xim\""
	elog "   ibus-daemon -d -x"
}

pkg_postrm() {
	use gtk && update_gtk_immodules
	use gtk3 && update_gtk3_immodules
	use python && python_mod_cleanup /usr/share/${PN}
	gnome2_icon_cache_update
}
