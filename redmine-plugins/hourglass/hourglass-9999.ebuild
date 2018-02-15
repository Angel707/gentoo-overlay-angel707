# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_RUBY="ruby22 ruby23"
inherit eutils depend.apache ruby-ng user

DESCRIPTION="Plugin to enhance the time tracking abilities, reports and REST-API"
HOMEPAGE="https://github.com/hicknhack-software/redmine_hourglass https://www.redmine.org/plugins/redmine_hourglass"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

if [ "${PV}" = "9999" ]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hicknhack-software/redmine_hourglass.git"
	KEYWORDS=""
	SRC_URI=""
	EGIT_CHECKOUT_DIR="${WORKDIR}/all"
else
	KEYWORDS="~amd64 ~arm ~x86"
fi

DOCS="README.md CHANGELOG.md"
NDOCS="CODE_OF_CONDUCT.md CONTRIBUTING.md GPL.txt"

# redmine support until 3.4 (2018-02-15)
ruby_add_bdepend "
	>=www-apps/redmine-3.0
	>=dev-ruby/execjs-2.6
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
	rm -rf ${NDOCS} || die

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
