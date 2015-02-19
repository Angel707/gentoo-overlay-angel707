# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/copycats/copycats-9999.ebuild,v 0.5 2015/02/05 23:25:49 angel707 Exp $

EAPI=5

inherit git-2
DESCRIPTION="Themes for Awesome WM 3.5+"
HOMEPAGE="https://github.com/copycat-killer/awesome-copycats"
SRC_URI=""
EGIT_REPO_URI="git://github.com/copycat-killer/awesome-copycats.git
	http://github.com/copycat-killer/awesome-copycats.git"

LICENSE="CC BY-NC-SA"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

DEPEND="x11-plugins/awesomewm-lain"
RDEPEND="${DEPEND}
	>=x11-wm/awesome-3.5
	dev-lang/lua
	media-fonts/terminus-font"

src_install() {
	# install docs
	dodoc README.rst
	# install themes
	insinto /usr/share/awesome/themes
	doins -r themes/*
	# install libs 'eminent', 'menugen' and 'scratchdrop'
	# note: lib 'lain' is installed separately
	insinto /usr/share/awesome/lib
	doins -r eminent menugen scratchdrop
	# install rc.lua* files
	insinto /usr/share/awesome/rc/copycats
	doins rc.lua.*
}
