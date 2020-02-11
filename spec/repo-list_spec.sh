# shellcheck shell=sh

Describe "repo-list"
	It "lists repositories in order of priority"
		When call repo-list
		The lines of the entire output should eq 3
		The first line of output should eq 'test'
		The second line of output should eq 'test-libraries-only'
		The third line of output should eq 'test-packages-only'
	End

	It "only lists repositories with libraries in them when -l is given"
		When call repo-list -l
		The lines of the entire output should eq 2
		The first line of output should eq 'test'
		The second line of output should eq 'test-libraries-only'
	End

	It "only lists repositories with packages in them when -p is given"
		When call repo-list -p
		The lines of the entire output should eq 2
		The first line of output should eq 'test'
		The second line of output should eq 'test-packages-only'
	End

	It "will error out if you give it an unknown argument"
		When call repo-list -z
		The status should eq 1
		The lines of the entire stderr should eq 2
		The first line of stderr should eq '!! unknown argument -- z'
	End
End
