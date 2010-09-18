# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

ECVS_SERVER="cvs.schmorp.de:/schmorpforge"
ECVS_MODULE="rxvt-unicode"
ECVS_USER="anonymous"
ECVS_PASS=""

inherit autotools flag-o-matic cvs

DESCRIPTION="rxvt clone with xft and unicode support"
HOMEPAGE="http://software.schmorp.de/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="+truetype +perl iso14755 +afterimage +xterm-color wcwidth vanilla +spacing"

# see bug #115992 for modular x deps
RDEPEND="x11-libs/libX11
	x11-libs/libXft
	afterimage? ( media-libs/libafterimage )
	x11-libs/libXrender
	perl? ( dev-lang/perl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	x11-proto/xproto"

S="${WORKDIR}/${PN}"

src_unpack() {
	cvs_src_unpack
	cd "${S}"

	local tdir=/usr/share/terminfo
	if use xterm-color; then
		epatch doc/urxvt-8.2-256color.patch
		sed -e \
			's/^\(rxvt-unicode\)/\1256/;s/colors#88/colors#256/;s/pairs#256/pairs#32767/' \
			doc/etc/rxvt-unicode.terminfo > doc/etc/rxvt-unicode256.terminfo
		sed -i -e \
			"s~^\(\s\+@TIC@.*\)~\1\n\t@TIC@ -o "${D}/${tdir}" \$(srcdir)/etc/rxvt-unicode256.terminfo~" \
			doc/Makefile.in
	fi

	use wcwidth && epatch doc/wcwidth.patch

	# https://bugs.gentoo.org/show_bug.cgi?id=240165
	epatch "${FILESDIR}/${PN}-9.06_no-urgency-if-focused.diff"

	if ! use vanilla; then
		# https://bugs.gentoo.org/show_bug.cgi?id=237271
		epatch "${FILESDIR}/${PN}-9.05_no-MOTIF-WM-INFO.patch"
	fi

	use spacing && epatch "${FILESDIR}/${PN}-spacing.patch"

	sed -i -e \
		"s~@TIC@ \(\$(srcdir)/etc/rxvt\)~@TIC@ -o "${D}/${tdir}" \1~" \
		doc/Makefile.in

	eautoreconf
}

src_compile() {
	local myconf=''

	use iso14755 || myconf='--disable-iso14755'
	use xterm-color && myconf="$myconf --enable-xterm-colors=256"

	econf --enable-everything \
		$(use_enable truetype xft) \
		$(use_enable afterimage) \
		$(use_enable perl) \
		--disable-text-blink \
		${myconf}

	emake || die "emake failed"

	sed -i -e 's/RXVT_BASENAME = "rxvt"/RXVT_BASENAME = "urxvt"/' \
		"${S}"/doc/rxvt-tabbed || die "tabs sed failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc README.FAQ Changes
	cd "${S}"/doc
	dodoc README* changes.txt etc/* rxvt-tabbed
}

pkg_postinst() {
	einfo "urxvt now always uses TERM=rxvt-unicode so that the"
	einfo "upstream-supplied terminfo files can be used."
	echo
	elog "Upstream does not support Gentoo and Gentoo does not support this"
	elog "live cvs ebuild. If you have any questions about this ebuild, please"
	elog "contact the #berkano IRC channel on freenode, or post at the forum"
	elog "support thread at http://forums.gentoo.org/viewtopic-t-508174.html"
	echo
}
