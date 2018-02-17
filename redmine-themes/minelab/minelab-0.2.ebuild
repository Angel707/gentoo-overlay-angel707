# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_RUBY="ruby22 ruby23"
inherit eutils depend.apache ruby-ng user

DESCRIPTION="GitLab inspired Sass theme for Redmine"
HOMEPAGE="https://github.com/hardpixel/minelab https://www.redmine.org/projects/redmine/wiki/Theme_List#Minelab"
SRC_URI="https://github.com/hardpixel/minelab/archive/v${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="~amd64"
LICENSE="GPL-3"
SLOT="0"
IUSE=""

DOCS="README.md"
NDOCS=".gitignore"

# redmine support until 3.4 or higher
ruby_add_bdepend "
	>=www-apps/redmine-3.0
"

REDMINE_DIR="/var/lib/redmine"
REDMINE_THEMES_DIR="${REDMINE_DIR}/public/themes"
REDMINE_THEME_DIR="${REDMINE_THEMES_DIR}/${PN}"

all_ruby_prepare() {
	# rename redmine-theme-${P} to ${P} so that we don't need to redefine S
	if [[ -e redmine-theme-${PN}-${PV} ]]; then
		mv -f redmine-theme-${PN}-${PV} ${P}
	fi
}

all_ruby_install() {
	dodoc ${DOCS}
	rm -r ${DOCS} || die
	rm -rf ${NDOCS} || die

	insinto "${REDMINE_THEME_DIR}"
	doins -r .

	fowners redmine:redmine "${REDMINE_THEME_DIR}"
}

