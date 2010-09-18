# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gimp/gimp-2.6.10.ebuild,v 1.1 2010/07/09 15:21:01 scarabeus Exp $

EAPI=2
PYTHON_DEPEND="python? 2:2.5"
RESTRICT="mirror"

inherit eutils gnome2 fdo-mime multilib python

DESCRIPTION="GNU Image Manipulation Program"
HOMEPAGE="http://www.gimp.org/"
SRC_URI="ftp://ftp.gimp.org/pub/gimp/v2.7/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"

IUSE="alsa aalib altivec curl dbus debug doc exif gnome hal jpeg lcms mmx mng pdf png python smp sse svg tiff webkit wmf"

RDEPEND=">=dev-libs/glib-2.18.1
	>=x11-libs/gtk+-2.12.5
	>=x11-libs/pango-1.18.0
	x11-libs/libXpm
	>=media-libs/freetype-2.1.7
	>=media-libs/fontconfig-2.2.0
	>=media-libs/babl-0.1.0
	sys-libs/zlib
	dev-libs/libxml2
	dev-libs/libxslt
	x11-misc/xdg-utils
	x11-themes/hicolor-icon-theme
	>=media-libs/gegl-0.1.0
	aalib? ( media-libs/aalib )
	alsa? ( media-libs/alsa-lib )
	curl? ( net-misc/curl )
	dbus? ( dev-libs/dbus-glib )
	hal? ( sys-apps/hal )
	gnome? ( gnome-base/gvfs )
	webkit? ( net-libs/webkit-gtk )
	jpeg? ( >=media-libs/jpeg-6b-r2:0 )
	exif? ( >=media-libs/libexif-0.6.15 )
	lcms? ( =media-libs/lcms-1* )
	mng? ( media-libs/libmng )
	pdf? ( >=app-text/poppler-0.12.3-r3[cairo] )
	png? ( >=media-libs/libpng-1.2.2 )
	python?	( >=dev-python/pygtk-2.10.4 )
	tiff? ( >=media-libs/tiff-3.5.7 )
	svg? ( >=gnome-base/librsvg-2.8.0 )
	wmf? ( >=media-libs/libwmf-0.2.8 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12.0
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog* HACKING NEWS README*"

pkg_setup() {
	G2CONF="--enable-default-binary \
		--with-x \
		$(use_with aalib aa) \
		$(use_with alsa) \
		$(use_enable altivec) \
		$(use_with curl libcurl) \
		$(use_with dbus) \
		$(use_with hal) \
		$(use_with gnome gvfs) \
		--without-gnomevfs \
		$(use_with webkit) \
		$(use_with jpeg libjpeg) \
		$(use_with exif libexif) \
		$(use_with lcms) \
		$(use_enable mmx) \
		$(use_with mng libmng) \
		$(use_with pdf poppler) \
		$(use_with png libpng) \
		$(use_enable python) \
		$(use_enable smp mp) \
		$(use_enable sse) \
		$(use_with svg librsvg) \
		$(use_with tiff libtiff) \
		$(use_with wmf)"

	if use python; then
		python_set_active_version 2
	fi
}

src_install() {
	gnome2_src_install

	if use python; then
		python_convert_shebangs -r $(python_get_version) "${D}"
		python_need_rebuild
	fi
}

pkg_postinst() {
	gnome2_pkg_postinst

	use python && python_mod_optimize /usr/$(get_libdir)/gimp/2.0/python \
		/usr/$(get_libdir)/gimp/2.0/plug-ins
}

pkg_postrm() {
	gnome2_pkg_postrm

	use python && python_mod_cleanup /usr/$(get_libdir)/gimp/2.0/python \
		/usr/$(get_libdir)/gimp/2.0/plug-ins
}
