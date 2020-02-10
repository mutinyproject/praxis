# shellcheck shell=sh

#shellspec_spec_helper_configure() {
	export NO_COLOR=1

	export PATH="${PWD}/bin:${PATH}"

	export PRAXIS_LIBDIR="${PWD}/lib"

	export PRAXIS_BUILDDIR="${PWD}/spec/testdata/build"
	export PRAXIS_CACHEDIR="${PWD}/spec/testdata/cache"
	export PRAXIS_DBDIR="${PWD}/spec/testdata/db"
#}
