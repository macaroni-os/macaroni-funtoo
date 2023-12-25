#!/usr/bin/env python3
# encoding: utf-8

import os
import subprocess
import shutil
import libcalamares
import re


# List of the packages to remove
# on the installed rootfs at the
# end of the installation process.
# Temporary list to move with a file.
anise_packages2remove = [
    "macaroni/live-setup",
    "macaroni/live-setup-core",
    "macaroni/live-setup-xfce4",
    "macaroni/live-setup-gnome",
    "kernel-6.1/macaroni-initramfs",
    "kernel-5.10/macaroni-initramfs",
    "kernel-5.10/virtualbox-guest-additions",
    "kernel-6.1/virtualbox-guest-additions",
    "system/macaroni-funtoo-calamares",
    "virtual/calamares",
    "app-admin-5/calamares",
    # designer is a dep of libreoffice
    # that is needed for live ISO
    #"dev-qt-5/designer"
]


def setup_locales(install_path):
    locale_conf = libcalamares.globalstorage.value("localeConf")

    if not locale_conf:
        locale_conf = {
            'LANG': 'en_US.UTF-8',
            'LC_NUMERIC': 'en_US.UTF-8',
            'LC_TIME': 'en_US.UTF-8',
            'LC_MONETARY': 'en_US.UTF-8',
            'LC_PAPER': 'en_US.UTF-8',
            'LC_NAME': 'en_US.UTF-8',
            'LC_ADDRESS': 'en_US.UTF-8',
            'LC_TELEPHONE': 'en_US.UTF-8',
            'LC_MEASUREMENT': 'en_US.UTF-8',
            'LC_IDENTIFICATION': 'en_US.UTF-8'
        }

    target_locale_gen = "{!s}/etc/locale.gen".format(install_path)
    target_locale_gen_bak = target_locale_gen + ".bak"
    target_etc_default_path = "{!s}/etc/env.d/02locale".format(install_path)
    locales_supported_path = "{!s}/usr/share/i18n/SUPPORTED".format(install_path)

    locales_map = {}
    if os.path.exists(locales_supported_path):
        # POST: create a map with all locales and charmap
        with open(locales_supported_path) as fp:
            lines = fp.readlines()
            for line in lines:
                fields = line.split()
                locales_map[fields[0]] = fields[1]

    print("LOCALE_GEN_FILE", target_locale_gen)
    print("LOCALE_ENV_FILE", target_etc_default_path)

    if locale_conf['LANG'] in locales_map:
        charmap = locales_map[locale_conf['LANG']]
    else:
        charmap = 'UTF-8'

    # restore backup if available
    if os.path.exists(target_locale_gen_bak):
        shutil.copy2(target_locale_gen_bak, target_locale_gen)
        libcalamares.utils.debug(
                "Restored backup {!s} -> {!s}"
                .format(target_locale_gen_bak, target_locale_gen))
    elif locale_conf['LANG'] != 'en_US.utf-8':
        # Append the selected lang to the existing
        # /etc/locale.gen. I want mantain en_US.UTF-8 and C.UTF-8
        with open(target_locale_gen, "a") as lg:
            lg.write("{!s} {!s}\n".format(locale_conf['LANG'], charmap))

    #libcalamares.utils.target_env_call(['locale-gen', '-A'])
    libcalamares.utils.target_env_call(['locale-gen'])

    # Try to generate the string for eselect locale
    eselect_str = '%s.%s' % (
        locale_conf['LANG'].split(".")[0],
        charmap.lower().replace("-", ""),
    )
    libcalamares.utils.target_env_call(
        ['eselect', 'locale', 'list'],
    )
    libcalamares.utils.target_env_call(
        ['eselect', 'locale', 'set', eselect_str],
    )


def setup_audio(root_install_path):
    asound_state_filename = 'asound.state'
    asound_state_orig = '/etc/' + asound_state_filename
    if os.path.isfile(asound_state_orig) and os.access(asound_state_orig,
                                                       os.R_OK):
        asound_state_alsa_dest_1 = root_install_path + '/etc/'
        asound_state_alsa_dest_2 = root_install_path + '/var/lib/alsa/'
        os.makedirs(asound_state_alsa_dest_1, mode=0o755, exist_ok=True)
        os.makedirs(asound_state_alsa_dest_2, mode=0o755, exist_ok=True)
        shutil.copy2(asound_state_orig, asound_state_alsa_dest_1)
        shutil.copy2(asound_state_orig, asound_state_alsa_dest_2)


def run_postinst_script(root_install_path):
    hostname = libcalamares.globalstorage.value('hostname')
    libcalamares.utils.debug(
        'Found target hostname {!s}'.format(hostname))
    libcalamares.utils.target_env_call(
        ['/usr/share/macaroni/live-setup/postinst.sh',
         root_install_path, hostname])


def run():
    """ MacaroniOS Calamares Post-install module """
    # Get install path
    install_path = libcalamares.globalstorage.value('rootMountPoint')
    setup_locales(install_path)
    setup_audio(install_path)
    run_postinst_script(install_path)


    # Temporary. I hope to find a better way.
    libcalamares.utils.target_env_call([
        'userdel', '-f', '-r', 'macaroni',
    ])

    if len(anise_packages2remove) > 0:
        args = ["anise", "uninstall", "-y", "--force" ]
        args = args + anise_packages2remove
        # args = args + anise_packages2remove
        # libcalamares.utils.target_env_call(args)
        # Temporary trying to remove every package singolary
        #for pkg in anise_packages2remove:
        libcalamares.utils.target_env_call(args)

    # It's better run this after that is uninstalled macaroni initramfs
    # package.
    libcalamares.utils.target_env_call([
        'macaronictl', 'kernel', 'gi', '--all',
        '--set-links', '--purge', '--grub',
    ])

    libcalamares.utils.target_env_call([
        'chmod', 'u-s', '/usr/bin/pkexec',
    ])

    libcalamares.utils.target_env_call(['macaronictl', 'env-update'])

    return None
