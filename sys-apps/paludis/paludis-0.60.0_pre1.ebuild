# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/paludis/paludis-0.58.0.ebuild,v 1.1 2011/01/09 18:57:05 peper Exp $

EAPI="3"

inherit bash-completion eutils

DESCRIPTION="paludis, the other package mangler"
HOMEPAGE="http://paludis.pioto.org/"
SRC_URI="http://paludis.pioto.org/download/${P}.tar.bz2"

IUSE="accerso appareo doc instruo pbins pink portage python-bindings ruby-bindings search-index vim-syntax visibility xml zsh-completion"
LICENSE="GPL-2 vim-syntax? ( vim )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"

COMMON_DEPEND="
	>=app-admin/eselect-1.2.13
	>=app-shells/bash-3.2
	>=sys-devel/gcc-4.4
	dev-libs/libpcre[cxx]
	sys-apps/file
	pbins? ( >=app-arch/libarchive-2.8.4[xattr] )
	python-bindings? ( >=dev-lang/python-2.6 >=dev-libs/boost-1.41.0[python] )
	ruby-bindings? ( >=dev-lang/ruby-1.8 )
	xml? ( >=dev-libs/libxml2-2.6 )
	search-index? ( >=dev-db/sqlite-3 )"

DEPEND="${COMMON_DEPEND}
	doc? (
		|| ( >=app-doc/doxygen-1.5.3 <=app-doc/doxygen-1.5.1 )
		media-gfx/imagemagick
		python-bindings? ( dev-python/epydoc dev-python/pygments )
		ruby-bindings? ( dev-ruby/syntax dev-ruby/allison )
	)
	app-text/asciidoc
	dev-util/pkgconfig"

RDEPEND="${COMMON_DEPEND}
	sys-apps/sandbox"

# Keep syntax as a PDEPEND. It avoids issues when Paludis is used as the
# default virtual/portage provider.
PDEPEND="
	vim-syntax? ( >=app-editors/vim-core-7 )
	app-admin/eselect-package-manager"

PROVIDE="virtual/portage"

create-paludis-user() {
	enewgroup "paludisbuild"
	enewuser "paludisbuild" -1 -1 "/var/tmp/paludis" "paludisbuild,tty"
}

pkg_setup() {
	if id paludisbuild >/dev/null 2>/dev/null ; then
		if ! groups paludisbuild | grep --quiet '\<tty\>' ; then
			eerror "The 'paludisbuild' user is now expected to be a member of the"
			eerror "'tty' group. You should add the user to this group before"
			eerror "upgrading Paludis."
			die "Please add paludisbuild to tty group"
		fi
	fi

	create-paludis-user
}

src_configure() {
	local repositories=`echo default unavailable unpackaged | tr -s \  ,`
	local clients="cave"
	local allclients="accerso appareo instruo"

	for client in ${allclients} ; do
		if use ${client} ; then
			clients+=" ${client}"
		fi
	done

	clients=$(echo ${clients} | tr -s \  ,)

	local environments=`echo default $(usev portage ) | tr -s \  ,`
	econf \
		$(use_enable doc doxygen ) \
		$(use_enable pbins ) \
		$(use_enable pink ) \
		$(use_enable ruby-bindings ruby ) \
		$(useq ruby-bindings && useq doc && echo --enable-ruby-doc ) \
		$(use_enable python-bindings python ) \
		$(useq python-bindings && useq doc && echo --enable-python-doc ) \
		$(use_enable vim-syntax vim ) \
		$(use_enable visibility ) \
		$(use_enable xml ) \
		$(use_enable search-index ) \
		--with-vim-install-dir=/usr/share/vim/vimfiles \
		--with-repositories=${repositories} \
		--with-clients=${clients} \
		--with-environments=${environments} \
		|| die "econf failed"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS README NEWS

	use accerso && BASHCOMPLETION_NAME="accerso" dobashcompletion bash-completion/accerso
	use instruo && BASHCOMPLETION_NAME="instruo" dobashcompletion bash-completion/instruo
	BASHCOMPLETION_NAME="cave" dobashcompletion bash-completion/cave

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		doins zsh-completion/_paludis_packages
		doins zsh-completion/_cave
	fi
}

src_test() {
	# Work around Portage bugs
	export PALUDIS_DO_NOTHING_SANDBOXY="portage sucks"
	export BASH_ENV=/dev/null

	if [[ `id -u` == 0 ]] ; then
		# hate
		export PALUDIS_REDUCED_UID=0
		export PALUDIS_REDUCED_GID=0
	fi

	if ! emake check ; then
		eerror "Tests failed. Looking for files for you to add to your bug report..."
		find "${S}" -type f -name '*.epicfail' -or -name '*.log' | while read a ; do
			eerror "    $a"
		done
		die "Make check failed"
	fi
}

pkg_postinst() {
	pm_is_paludis=false
	if [[ -f ${ROOT}/etc/env.d/50package-manager ]] ; then
		pm_is_paludis=$( source ${ROOT}/etc/env.d/50package-manager ; [[ ${PACKAGE_MANAGER} == paludis ]] && echo true || echo false )
	fi

	if ! $pm_is_paludis ; then
		elog "If you are using paludis or cave as your primary package manager,"
		elog "you should consider running:"
		elog "    eselect package-manager set paludis"
	fi
}
