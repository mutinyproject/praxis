# shellcheck shell=sh

Describe "repo-update"
	It "updates all the repositories when given no arguments"
		When call repo-update
		The status should eq 0
		The lines of the entire stdout should eq 0
		The lines of the entire stderr should eq 3
		The line 1 of the stderr should eq \
			"!? unsure of how to update '${PRAXIS_DBDIR}/repositories/test'"
		The line 2 of the stderr should eq \
			"!? unsure of how to update '${PRAXIS_DBDIR}/repositories/test-libraries-only'"
		The line 3 of the stderr should eq \
			"!? unsure of how to update '${PRAXIS_DBDIR}/repositories/test-packages-only'"
	End

	It "updates only repositories given as arguments, if given any arguments"
		When call repo-update test test-libraries-only
		The status should eq 0
		The lines of the entire stdout should eq 0
		The lines of the entire stderr should eq 2
		The line 1 of the stderr should eq \
			"!? unsure of how to update '${PRAXIS_DBDIR}/repositories/test'"
		The line 2 of the stderr should eq \
			"!? unsure of how to update '${PRAXIS_DBDIR}/repositories/test-libraries-only'"
	End

	It "will error out if you give it an unknown argument"
		When call repo-update -z
		The status should eq 1
		The lines of the entire stderr should eq 2
		The first line of stderr should eq '!! unknown argument -- z'
	End

	It "does not touch repositories when -d (dry run) is specified"
		Pending \
			"testdata repositories don't currently have any commands that would be ran for them anyhow"
	End

	It "shows any new changes since the last update a repository"
		Pending "not yet certain of the best way to test this"
	End
End

