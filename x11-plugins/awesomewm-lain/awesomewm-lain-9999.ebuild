# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/vicious/vicious-2.1.0-r1.ebuild,v 1.1 2013/02/05 23:25:49 wired Exp $

EAPI=5

inherit git-2
DESCRIPTION="Layouts, widgets and utilities for Awesome WM 3.5+"
HOMEPAGE="https://github.com/copycat-killer/lain/wiki"
SRC_URI=""
EGIT_REPO_URI="git://github.com/copycat-killer/lain.git
	http://github.com/copycat-killer/lain.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="contrib"

DEPEND=""
RDEPEND="${DEPEND}
	>=x11-wm/awesome-3.5
	dev-lang/lua
	media-sound/alsa-utils  
	net-misc/curl
	media-gfx/imagemagick"

# dependencies:
# media-sound/alsa-utils requested by alsa, alsabar
# net-misc/curl requested by widgets accessing network resources (simpler to install and use than luasocket)
# media-gfx/imagemagick requested by album arts in mpd notifications (cairo doesn't do high quality filtering)

# contrib dependencies:
# widgets/contrib/ccurr needs the lua lib 'dkjson' which is not available over the gentoo portage tree

src_install() {
	# install docs
	dodoc README.rst
	# install lib 'lain'
	insinto /usr/share/awesome/lib/lain
	doins -r icons layout scripts util asyncshell.lua helpers.lua init.lua
	insinto /usr/share/awesome/lib/lain/widgets
	doins -r widgets/yawn widgets/*.lua
	# install contributions of lib 'lain'
	if use contrib; then
		insinto /usr/share/awesome/lib/lain/widgets
		doins -r widgets/contrib
		#newdoc contrib/README README.contrib
		ewarn "The contrib ccurr.lua needs the lua library 'dkjson'. Please install it, when you want to use it."
	fi
}
