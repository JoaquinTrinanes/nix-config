export def gpristine [] {
    git reset --hard
    git clean -d --force -x
}

export def gpoat [] {
    git push origin --all; git push origin --tags
}

export def gtv [] {
    git tag | lines | sort
}

