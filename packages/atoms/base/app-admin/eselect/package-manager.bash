# -*-eselect-*-  vim: ft=eselect
# Copyright (c) 2005-2019 Gentoo Authors
#
# This file is part of the 'eselect' tools framework.
#
# eselect is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 2 of the License, or (at your option) any later
# version.
#
# eselect is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# eselect.  If not, see <http://www.gnu.org/licenses/>.

# package_manager PRIVATE
# Return the package manager we're going to use.
package_manager() {
	local pm
	case ${PACKAGE_MANAGER} in
		portage) pm=portage ;;
		pkgcore) pm=pkgcore ;;
		paludis) pm=paludis ;;
	esac
	echo "${pm:-portage}"
}

# portageq
# Run portageq. Redirect stderr
portageq() {
	command portageq "$@" 2>/dev/null
}

# run_paludis PRIVATE
# Run CAVE (defaults to "cave"). Redirect stderr
run_paludis() {
	${CAVE:-cave} "$@" 2>/dev/null
}

# arch
# Return the architecture we're running on...
arch() {
	local ret=$(envvar sys-devel/gcc ARCH)

	if [[ -n ${EPREFIX} && -n ${ret} && ${ret%-*} = "${ret}" ]]; then
		# prefix/linux profiles lie about their ARCH
		case $(envvar sys-devel/gcc KERNEL) in
			linux) ret+="-linux" ;;
			*)
				write_warning_msg \
					"Failed to determine \${ARCH}." \
					"Please submit a bug report."
				return 1
				;;
		esac
	fi

	# $arch will be null if there's no current make.profile symlink.
	# We cannot get a list of valid profiles without it.
	if [[ -z ${ret} ]]; then
		if [[ -n ${ROOT} && ${ROOT} != "/" ]]; then
			write_warning_msg \
				"Failed to determine \${ARCH}." \
				"Is your make.profile symlink valid?"
			return 1
		fi

		# Try to determine arch from HOSTTYPE and OSTYPE, which are
		# derived from the GNU triplet (at build time of bash)
		case ${HOSTTYPE} in
			aarch64*)  	ret=arm64 	;;
			alpha*) 	ret=alpha	;;
			arm*)   	ret=arm 	;;
			hppa*)  	ret=hppa	;;
			i?86)   	ret=x86 	;;
			ia64*)  	ret=ia64	;;
			m68k*)  	ret=m68k	;;
			mips*)  	ret=mips	;;
			nios2)  	ret=nios2	;;
			powerpc64*)	ret=ppc64	;;
			powerpc*)	ret=ppc 	;;
			riscv*) 	ret=riscv	;;
			s390*)  	ret=s390	;;
			sh*)    	ret=sh  	;;
			sparc64*) 	ret=sparc64	;;
			sparc*) 	ret=sparc	;;
			x86_64) 	ret=amd64	;;
			*)
				write_warning_msg \
					"Unknown architecture \"${HOSTTYPE}\"." \
					"Please submit a bug report."
				return 1
				;;
		esac

		if [[ -z ${EPREFIX} ]]; then
			case ${OSTYPE} in
				linux*) 	;;
				dragonfly*)	ret+="-dfly"	;;
				freebsd*)	ret+="-fbsd"	;;
				netbsd*)	ret+="-nbsd"	;;
				openbsd*)	ret+="-obsd"	;;
				*)
					write_warning_msg \
						"Unknown OS \"${OSTYPE}\"." \
						"Please submit a bug report."
					return 1
					;;
			esac
		else
			# Prefix architectures
			if [[ ${ret} = amd64 && ${OSTYPE} != linux* ]]; then
				# amd64 is sometimes called x64 on Prefix
				ret=x64
			fi
			case ${OSTYPE} in
				aix*)   	ret+="-aix" 	;;
				cygwin*)	ret+="-cygwin"	;;
				darwin*)	ret+="-macos"	;;
				freebsd*)	ret+="-freebsd"	;;
				hpux*)  	ret+="-hpux"	;;
				interix*)	ret+="-interix"	;;
				linux*) 	ret+="-linux"	;;
				mint*)  	ret+="-mint"	;;
				netbsd*)	ret+="-netbsd"	;;
				openbsd*)	ret+="-openbsd"	;;
				solaris*)	ret+="-solaris"	;;
				winnt*) 	ret+="-winnt"	;;
				*)
					write_warning_msg \
						"Unknown OS \"${OSTYPE}\"." \
						"Please submit a bug report."
					return 1
					;;
			esac
		fi
	fi

	echo "${ret}"
}

# envvar
# Return the contents of environment variable $2 as seen by package manager
# for package $1.
envvar() {
	[[ $# -eq 2 ]] || die "envvar expects exactly 2 arguments"
	case $(package_manager) in
		# portage does not support per-package envvar lookup
		portage) portageq envvar "$2" ;;
		pkgcore) pinspect portageq envvar "$2" ;;
		paludis) run_paludis print-id-environment-variable --best \
			--variable-name "$2" --format '%v\n' "$1" ;;
	esac
}

# best_version
# Return true if package $1 is available in ${ROOT}
best_version() {
	[[ $# -eq 1 ]] || die "best_version expects exactly one argument"
	case $(package_manager) in
		portage) portageq best_version "${EROOT:-/}" "$1" ;;
		pkgcore) pinspect portageq best_version "${ROOT:-/}" "$1" ;;
		paludis) run_paludis print-best-version --format name-version "$1" ;;
	esac
}

# has_version
# Return true if package $1 is available in ${ROOT}
has_version() {
	[[ $# -eq 1 ]] || die "has_version expects exactly one argument"
	case $(package_manager) in
		portage) portageq has_version "${EROOT:-/}" "$1" ;;
		pkgcore) pinspect portageq has_version "${ROOT:-/}" "$1" ;;
		paludis) run_paludis has-version "$1" ;;
	esac
}

# get_repositories
# return list of repositories known to the package manager
get_repositories() {
	case $(package_manager) in
		portage) portageq get_repos "${EROOT:-/}" ;;
		pkgcore) pinspect portageq get_repos "${ROOT:-/}" ;;
		paludis) run_paludis print-repositories ;;
	esac
}

# get_repo_news_dir
# return the directory where to find GLEP 42 news items for repository $1
get_repo_news_dir() {
	[[ $# -eq 1 ]] || die "get_repo_news_dir expects exactly one argument"
	local repo=$1
	case $(package_manager) in
		portage) echo "$(portageq get_repo_path \
			"${EROOT:-/}" "${repo}")/metadata/news" ;;
		pkgcore) pinspect portageq get_repo_news_path "${ROOT:-/}" "${repo}" ;;
		paludis) run_paludis print-repository-metadata ${repo} \
			--raw-name newsdir --format '%v\n' ;;
	esac
}

# env_update
# Run env-update command, if available with the package manager
# If $1 is non-zero: also run ldconfig to update /etc/ld.so.cache
env_update() {
	local noldconfig
	[[ $1 -ne 0 ]] || noldconfig=y
	case $(package_manager) in
		portage)
			if [ -e /etc/macaroni/release ] ; then
				"/usr/bin/macaronictl" env-update ${noldconfig:+--ldconfig=false}
			else
				"/usr/sbin/env-update" ${noldconfig:+--no-ldconfig}
			fi
			;;
		pkgcore) pmaint env-update ${noldconfig:+--skip-ldconfig} ;;
		paludis) return 127 ;;
	esac
}
