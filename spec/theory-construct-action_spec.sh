# shellcheck shell=sh

Describe "theory-construct-action"
    It "requires at least one theory as an argument"
        When call theory-construct-action
        The status should eq 22
        The stderr should eq 'usage: theory-construct-action [-r] THEORY...'
        The lines of stderr should eq 1
    End

    It "will error out if you give it an unknown argument"
        When call theory-construct-action -z
        The status should eq 22
        The lines of the entire stderr should eq 2
        The first line of stderr should eq 'error: unknown argument -- z'
    End

End
