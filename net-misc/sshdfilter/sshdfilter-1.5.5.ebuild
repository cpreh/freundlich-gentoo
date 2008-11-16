# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils
DESCRIPTION="Protects sshd from bruteforce attacks"
HOMEPAGE="http://www.csc.liv.ac.uk/~greg/sshdfilter/"
SRC_URI="http://www.csc.liv.ac.uk/~greg/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-1"
KEYWORDS="x86"
IUSE=""
RDEPEND="virtual/ssh
        dev-lang/perl
        net-firewall/iptables"

src_install(){
	cat ${FILESDIR}/gentoo.partconf >> etc/sshdfilterrc
	insinto /etc/
	newins etc/sshdfilterrc sshdfilterrc
	newsbin source/sshdfilter.pl sshdfilter
#       exeinto /etc/init.d/
#       doexe "${FILESDIR}"/sshdfilter
	doman man/sshdfilter.1 man/sshdfilterrc.5
}
pkg_postinst(){
	einfo "Please edit /etc/sshdfilterrc to suit your needs."
	ewarn "Run emerge --config sshdfilter to generate the needed iptables"
	ewarn "chain and jump."
	epause
}

pkg_config(){
	einfo "The following commands will be executed:"
	einfo "iptables -N SSHD"
	einfo "iptables -I INPUT -p tcp -m tcp --dport 22 -j SSHD"
	einfo "/etc/init.d/iptables save"
	einfo "Press ENTER to execute and Control-C to abort."
	read
	iptables -N SSHD
	iptables -I INPUT -p tcp -m tcp --dport 22 -j SSHD
	/etc/init.d/iptables save
}

