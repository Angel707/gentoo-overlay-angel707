# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_RUBY="ruby22 ruby23"
inherit eutils depend.apache ruby-ng user

DESCRIPTION="Plugin to group issues into deploys and send notifications (e-mails) when needed"
HOMEPAGE="https://zapic0.github.io/deployer/ https://github.com/zapic0/deployer https://www.redmine.org/plugins/deployer"

LICENSE="MIT"
SLOT="0"
IUSE=""

if [ "${PV}" = "99999999" ]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zapic0/deployer.git"
	KEYWORDS="-*"
	SRC_URI=""
	EGIT_CHECKOUT_DIR="${WORKDIR}/all"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zapic0/deployer.git"
	KEYWORDS="~amd64 ~arm ~x86"
	SRC_URI=""
	EGIT_BRANCH="master"
	EGIT_COMMIT_DATE="${PV:0:4}-${PV:4:2}-${PV:6:2}"
	EGIT_CHECKOUT_DIR="${WORKDIR}/all"
fi

DOCS="README.md README.rdoc"
NDOCS="screenshots"

# redmine support until 3.5 and 4.0 (2018-02-15)
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
