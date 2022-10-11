#!/usr/bin/env python3
# encoding: utf-8

import os
import shutil
import libcalamares


# List of the packages to remove
# on the installed rootfs at the
# end of the installation process.
luet_packages2remove = [
    "macaroni/live-setup-server",
    "kernel/macaroni-lts-initramfs",
    "kernel-5.10/virtualbox-guest-additions",
    "kernel-5.4/virtualbox-guest-additions",
    "macaroni/calamares-server",
    "virtual/calamares",
    "app-admin-5/calamares",
    "dev-qt-5/designer"
]


def setup_locales(install_path):
    locale_conf = libcalamares.globalstorage.value("localeConf")

    if not locale_conf:
        locale_conf = {
            'LANG': 'en_US.utf-8',
            'LC_NUMERIC': 'en_US.utf-8',
            'LC_TIME': 'en_US.utf-8',
            'LC_MONETARY': 'en_US.utf-8',
            'LC_PAPER': 'en_US.utf-8',
            'LC_NAME': 'en_US.utf-8',
            'LC_ADDRESS': 'en_US.utf-8',
            'LC_TELEPHONE': 'en_US.utf-8',
            'LC_MEASUREMENT': 'en_US.utf-8',
            'LC_IDENTIFICATION': 'en_US.utf-8'
        }

    target_locale_gen = "{!s}/etc/locale.gen".format(install_path)
    target_locale_gen_bak = target_locale_gen + ".bak"
    target_etc_default_path = "{!s}/etc/env.d/02locale".format(install_path)

    # restore backup if available
    if os.path.exists(target_locale_gen_bak):
        shutil.copy2(target_locale_gen_bak, target_locale_gen)
        libcalamares.utils.debug(
                "Restored backup {!s} -> {!s}"
                .format(target_locale_gen_bak, target_locale_gen))

    libcalamares.utils.target_env_call(['locale-gen', '-A'])
    libcalamares.utils.target_env_call([
        'localectl', 'set-locale', locale_conf['LANG']
    ])

    # write /etc/default/locale if /etc/default exists and is a dir
    if os.path.isdir(target_etc_default_path):
        with open(os.path.join(target_etc_default_path, "locale"), "w") as edl:
            for k, v in locale_conf.items():
                edl.write("{!s}={!s}\n".format(k, v))
        libcalamares.utils.debug('{!s} done'.format(target_etc_default_path))


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

    #configure_services(install_path)

    if len(luet_packages2remove) > 0:
        args = ["luet", "uninstall", "-y", "--force" ]
        args = args + luet_packages2remove
        libcalamares.utils.target_env_call(args)

    # It's better run this after that is uninstalled macaroni initramfs package.
    libcalamares.utils.target_env_call([
        'macaronictl', 'kernel', 'gi', '--all',
        '--set-links', '--purge', '--grub',
    ])

    libcalamares.utils.target_env_call([
        'chmod', 'u-s', '/usr/bin/pkexec',
    ])

    libcalamares.utils.target_env_call(['env-update'])

    return None
