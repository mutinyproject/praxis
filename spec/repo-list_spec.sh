# shellcheck shell=sh

Describe "repo-list"
	It "lists repositories in order of priority"
		stdout() {
			%text
			#|test
			#|test-libraries-only
			#|test-packages-only
		}

		When call repo-list
		The status should eq 0
		The stdout should eq "$(stdout)"
	End

	It "only lists repositories with libraries in them when -l is given"
		stdout() {
			%text
			#|test
			#|test-libraries-only
		}

		When call repo-list -l
		The status should eq 0
		The stdout should eq "$(stdout)"
	End

	It "only lists repositories with packages in them when -p is given"
		stdout() {
			%text
			#|test
			#|test-packages-only
		}

		When call repo-list -p
		The status should eq 0
		The stdout should eq "$(stdout)"
	End

	It "will error out if you give it an unknown argument"
		When call repo-list -z
		The status should eq 1
		The lines of the entire stderr should eq 2
		The first line of stderr should eq '!! unknown argument -- z'
	End
End
