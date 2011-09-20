# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit games cmake-utils subversion

DESCRIPTION="A PlayStation 2 emulator"
HOMEPAGE="http://www.pcsx2.net"
ESVN_REPO_URI="http://pcsx2.googlecode.com/svn/trunk"
ESVN_PROJECT="pcsx2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"
if use amd64; then
	ABI="x86"
fi
if use debug; then
	CMAKE_BUILD_TYPE="Debug"
else
	CMAKE_BUILD_TYPE="Release"
fi

DEPEND="dev-cpp/sparsehash
	amd64? ( media-gfx/nvidia-cg-toolkit[multilib]
		app-emulation/emul-linux-x86-baselibs
		app-emulation/emul-linux-x86-opengl
		app-emulation/emul-linux-x86-xlibs
		app-emulation/emul-linux-x86-gtklibs
		app-emulation/emul-linux-x86-soundlibs
		app-emulation/emul-linux-x86-wxGTK )"
RDEPEND="${DEPEND}"

src_configure() {
	# tell cmake to use 32 bit library
	if use amd64; then
		mylibpath="/usr/lib32"
	else
		mylibpath="/usr/lib"
	fi

	mycmakeargs="
		-DPACKAGE_MODE=1
		-DCMAKE_INSTALL_PREFIX=/usr
		-DCMAKE_LIBRARY_PATH=${mylibpath}
		-DwxWidgets_CONFIG_EXECUTABLE=/usr/bin/wx-config-32
		-DCG_LIBRARY=/opt/nvidia-cg-toolkit/lib32/libCg.so
		-DCG_GL_LIBRARY=/opt/nvidia-cg-toolkit/lib32/libCgGL.so
		"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install DESTDIR=${D}

	# move binary files to correct directory
	mkdir -p ${D}/usr/games/bin
	mv ${D}/usr/bin/* ${D}/usr/games/bin || die

	prepgamesdirs
}

pkg_postinst() {
	if use amd64; then
		einfo "We currently use 64bit dev-cpp/sparsehash for compiling pcsx2"
		einfo "since sparsehash installation contains only header files."
		einfo "If you encounter any problems with that, try"
		einfo ""
		einfo "    ABI=\"x86\" emerge sparsehash"
		einfo ""
		einfo "and remerge pcsx2 before reporting bugs."
	fi
}
