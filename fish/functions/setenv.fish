#!/usr/bin/env fish

# setenv is compatible in both Zsh and Fish
function setenv
    if [ $argv[1] = PATH ]
        # Replace colons and spaces with newlines
        set -gx PATH (echo $argv[2] | tr ': ' \n)
    else
        set -gx $argv
    end
 end

