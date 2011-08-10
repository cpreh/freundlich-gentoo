# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/nvidia-cuda-sdk/nvidia-cuda-sdk-4.0.ebuild,v 1.1 2011/05/29 20:26:10 spock Exp $

EAPI=2

inherit eutils toolchain-funcs

DESCRIPTION="NVIDIA CUDA Software Development Kit"
HOMEPAGE="http://developer.nvidia.com/cuda"

CUDA_V=${PV//_/-}
DIR_V=${CUDA_V//./_}
DIR_V=${DIR_V//beta/Beta}

SRC_URI="http://developer.download.nvidia.com/compute/cuda/${DIR_V}/sdk/gpucomputingsdk_${CUDA_V}.17_linux.run"
LICENSE="CUDPP"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug +doc +examples opencl +cuda"

RDEPEND=">=dev-util/nvidia-cuda-toolkit-4.0
	examples? ( >=x11-drivers/nvidia-drivers-260.19.21 )
	media-libs/freeglut"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

RESTRICT="binchecks"

src_unpack() {
	unpack_makeself
}

src_compile() {
	if ! use examples; then
		return
	fi
	local myopts=""

	if use debug; then
		myopts="${myopts} dbg=1"
	fi

	cd "${S}/sdk"

	if use cuda; then
		cd C
		# cuda-install specifies where cuda was installed (not where it _will_
		# be installed)
		emake cuda-install=/opt/cuda ${myopts} || die
		cd ..
	fi

	if use opencl; then
		cd OpenCL
		emake || die
		cd ..
	fi
}

src_prepare() {
	cd "${S}"
	epatch "${FILESDIR}"/${P}-removeexamples.patch
}

src_install() {
	cd "${S}/sdk"

	if ! use doc; then
		rm -rf *.txt doc */doc */Samples.htm */releaseNotesData
	fi

	if ! use examples; then
		rm -rf bin */bin */tools
	fi

	for f in $(find .); do
		local t="$(dirname ${f})"
		if [[ "${t/obj\/}" != "${t}" || "${t##*.}" == "a" ]]; then
			continue
		fi

		if [[ ! -d "${f}" ]]; then
			if [[ -x "${f}" ]]; then
				exeinto "/opt/cuda/sdk/${t}"
				doexe "${f}"
			else
				insinto "/opt/cuda/sdk/${t}"
				doins "${f}"
			fi
		fi
	done
}
