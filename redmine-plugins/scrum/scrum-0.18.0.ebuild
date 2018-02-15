# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_RUBY="ruby22 ruby23"
inherit eutils depend.apache ruby-ng user

DESCRIPTION="Plugin to manage Scrum projects with Redmine"
HOMEPAGE="https://redmine.ociotec.com/projects/redmine-plugin-scrum https://www.redmine.org/plugins/scrum-plugin"
SRC_URI="https://redmine.ociotec.com/attachments/download/476/scrum-v${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="~amd64"
LICENSE="CC BY-ND 4.0"
SLOT="0"
IUSE=""

DOCS="README.rdoc"

# redmine support until 3.4
ruby_add_bdepend "
	>=www-apps/redmine-3.0
"

REDMINE_DIR="/var/lib/redmine"
REDMINE_PLUGINS_DIR="${REDMINE_DIR}/plugins"
REDMINE_PLUGIN_DIR="${REDMINE_PLUGINS_DIR}/${PN}"

all_ruby_prepare() {
	# rename ${PN} to ${P} so that we don't need to redefine S
	if [[ -e ${PN} ]]; then
		mv -f ${PN} ${P}
	fi
}

all_ruby_install() {
	dodoc ${DOCS}
	rm -r ${DOCS} || die

	insinto "${REDMINE_PLUGIN_DIR}"
	doins -r .

	fowners -R redmine:redmine \
		"${REDMINE_PLUGIN_DIR}/config"

	fowners redmine:redmine "${REDMINE_PLUGIN_DIR}"

	# protect sensitive data
	fperms -R go-rwx \
		"${REDMINE_PLUGIN_DIR}/config"
}

pkg_postinst() {
	elog "Execute the following command to setup plugin:"
	elog
	elog "# emerge --config \"=${CATEGORY}/${PF}\""
}

pkg_config() {
	local RAILS_ENV=${RAILS_ENV:-production}
	if [[ ! -L /usr/bin/ruby ]]; then
		eerror "/usr/bin/ruby is not a valid symlink to any ruby implementation."
		eerror "Please update it via `eselect ruby`"
		die
	fi
	if [[ $RUBY_TARGETS != *$( eselect ruby show | awk 'NR==2' | tr  -d ' '  )* ]]
	then
		eerror "/usr/bin/ruby is currently not included in redmine's ruby targets:"
		eerror "${RUBY_TARGETS}."
		eerror "Please update it via `eselect ruby`"
		die
	fi
	local RUBY=${RUBY:-ruby}

	cd "${EROOT%/}${REDMINE_PLUGINS_DIR}" || die
	einfo "Migrate redmine plugins."
	RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake redmine:plugins:migrate || die
}
