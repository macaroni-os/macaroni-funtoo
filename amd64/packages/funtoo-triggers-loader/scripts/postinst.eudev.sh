eudev_setup() {
	rmdir "${EROOT}"dev/loop 2>/dev/null
	if [[ -d ${EROOT}dev/loop ]]; then
		ewarn "Please make sure your remove /dev/loop,"
		ewarn "else losetup may be confused when looking for unused devices."
	fi

	# REPLACING_VERSIONS should only ever have zero or 1 values but in case it doesn't,
	# process it as a list.  We only care about the zero case (new install) or the case where
	# the same version is being re-emerged.  If there is a second version, allow it to abort.
	local rv rvres=doitnew
	for rv in ${REPLACING_VERSIONS} ; do
		if [[ ${rvres} == doit* ]]; then
			if [[ ${rv%-r*} == ${PV} ]]; then
				rvres=doit
			else
				rvres=${rv}
			fi
		fi
	done

	if use hwdb && has_version 'sys-apps/hwids[udev]'; then
		udevadm hwdb --update --root="${ROOT%/}"

		# https://cgit.freedesktop.org/systemd/systemd/commit/?id=1fab57c209035f7e66198343074e9cee06718bda
		# reload database after it has be rebuilt, but only if we are not upgrading
		if [[ ${rvres} == doit* ]] && [[ ${ROOT%/} == "" ]]; then
			udevadm control --reload
		fi
	fi
	if [[ ${rvres} != doitnew ]]; then
		ewarn
		ewarn "You need to restart eudev as soon as possible to make the"
		ewarn "upgrade go into effect:"
		ewarn "\t/etc/init.d/udev --nodeps restart"
	fi

	if use rule-generator && \
	[[ -x $(type -P rc-update) ]] && rc-update show | grep udev-postmount | grep -qsv 'boot\|default\|sysinit'; then
		ewarn
		ewarn "Please add the udev-postmount init script to your default runlevel"
		ewarn "to ensure the legacy rule-generator functionality works as reliably"
		ewarn "as possible."
		ewarn "\trc-update add udev-postmount default"
	fi

	elog
	elog "For more information on eudev on Gentoo, writing udev rules, and"
	elog "fixing known issues visit: https://wiki.gentoo.org/wiki/Eudev"


}
