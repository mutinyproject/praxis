# shellcheck shell=sh

Describe "repo-list"
	It "lists all repositories"
		When call repo-list
		The first line of output should eq 'test'
		The second line of output should eq 'test-libraries-only'
		The third line of output should eq 'test-packages-only'
		The lines of the entire output should eq 3
	End

	It "only lists repositories with libraries in them when -l is given"
		When call repo-list -l
		The first line of output should eq 'test'
		The second line of output should eq 'test-libraries-only'
		The lines of the entire output should eq 2
	End

	It "only lists repositories with packages in them when -p is given"
		When call repo-list -p
		The first line of output should eq 'test'
		The second line of output should eq 'test-packages-only'
		The lines of the entire output should eq 2
	End

	It "will error out if you give it an argument that isn't -[lp]"
		When call repo-list -z
		The first line of stderr should eq '!! unknown argument -- z'
		The lines of the entire stderr should eq 2
		The status should eq 1
	End
End
