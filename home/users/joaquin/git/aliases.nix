{
  home.shellAliases = {
    "g" = "git";
    "ga" = "git add";
    gaa = "git add --all";
    gapa = "git add --patch";
    gau = "git add --update";
    gav = "git add --verbose";
    gap = "git apply";
    gapt = "git apply --3way";

    gb = "git branch";
    gba = "git branch --all";
    gbd = "git branch --delete";
    gbD = "git branch --delete --force";
    gbl = "git blame -b -w";
    gbnm = "git branch --no-merged";
    gbr = "git branch --remote";
    gbs = "git bisect";
    gbsb = "git bisect bad";
    gbsg = "git bisect good";
    gbsr = "git bisect reset";
    gbss = "git bisect start";

    gc = "git commit --verbose";
    "gc!" = "git commit --verbose --amend";
    gcn = "git commit --verbose --no-edit";
    "gcn!" = "git commit --verbose --no-edit --amend";
    gca = "git commit --verbose --all";
    "gca!" = "git commit --verbose --all --amend";
    "gcan!" = "git commit --verbose --all --no-edit --amend";
    "gcans!" = "git commit --verbose --all --signoff --no-edit --amend";
    gcam = "git commit --all --message";
    gcsm = "git commit --signoff --message";
    gcas = "git commit --all --signoff";
    gcasm = "git commit --all --signoff --message";
    gcb = "git checkout -b";
    gcd = "git checkout develop";
    gcf = "git config --list";

    gcl = "git clone --recurse-submodules";
    gclean = "git clean --interactive -d";
    #   gpristine [] {
    #     git reset --hard
    #     git clean -d --force -x
    # }
    gcmsg = "git commit --message";
    gco = "git checkout";
    gcor = "git checkout --recurse-submodules";
    gcount = "git shortlog --summary --numbered";
    gcp = "git cherry-pick";
    gcpa = "git cherry-pick --abort";
    gcpc = "git cherry-pick --continue";
    gcs = "git commit --gpg-sign";
    gcss = "git commit --gpg-sign --signoff";
    gcssm = "git commit --gpg-sign --signoff --message";

    gd = "git diff";
    gdca = "git diff --cached";
    gdcw = "git diff --cached --word-diff";
    gdct = "git describe --tags (git rev-list --tags --max-count=1)";
    gds = "git diff --staged";
    gdt = "git diff-tree --no-commit-id --name-only -r";
    gdup = "git diff @{upstream}";
    gdw = "git diff --word-diff";

    gf = "git fetch";
    gfo = "git fetch origin";

    gg = "git gui citool";
    gga = "git gui citool --amend";

    ghh = "git help";

    gignore = "git update-index --assume-unchanged";

    gl = "git pull";
    glg = "git log --stat";
    glgp = "git log --stat --patch";
    glgg = "git log --graph";
    glgga = "git log --graph --decorate --all";
    glgm = "git log --graph --max-count=10";
    glo = "git log --oneline --decorate";
    glog = "git log --oneline --decorate --graph";
    gloga = "git log --oneline --decorate --graph --all";

    gm = "git merge";
    gmtl = "git mergetool --no-prompt";
    gmtlvim = "git mergetool --no-prompt --tool=vimdiff";
    gma = "git merge --abort";

    gp = "git push";
    gpd = "git push --dry-run";
    gpf = "git push --force-with-lease";
    "gpf!" = "git push --force";
    #   gpoat [] {
    #     git push origin --all; git push origin --tags
    # }
    gpr = "git pull --rebase";
    gpu = "git push upstream";
    gpv = "git push --verbose";

    gr = "git remote";
    gpra = "git pull --rebase --autostash";
    gprav = "git pull --rebase --autostash --verbose";
    gprv = "git pull --rebase --verbose";
    gra = "git remote add";
    grb = "git rebase";
    grba = "git rebase --abort";
    grbc = "git rebase --continue";
    grbd = "git rebase develop";
    grbi = "git rebase --interactive";
    grbo = "git rebase --onto";
    grbs = "git rebase --skip";
    grev = "git revert";
    grh = "git reset";
    grhh = "git reset --hard";
    grm = "git rm";
    grmc = "git rm --cached";
    grmv = "git remote rename";
    grrm = "git remote remove";
    grs = "git restore";
    grset = "git remote set-url";
    grss = "git restore --source";
    grst = "git restore --staged";
    grt = "cd (git rev-parse --show-toplevel or echo .)";
    gru = "git reset --";
    grup = "git remote update";
    grv = "git remote --verbose";

    gsb = "git status --short --branch";
    gsd = "git svn dcommit";
    gsh = "git show";
    gsi = "git submodule init";
    gsps = "git show --pretty=short --show-signature";
    gsr = "git svn rebase";
    gss = "git status --short";
    gs = "git status --short --branch";

    gstaa = "git stash apply";
    gstc = "git stash clear";
    gstd = "git stash drop";
    gstl = "git stash list";
    gstp = "git stash pop";
    gsts = "git stash show --text";
    gstu = "gsta --include-untracked";
    gstall = "git stash --all";
    gsu = "git submodule update";
    gsw = "git switch";
    gswc = "git switch --create";

    gts = "git tag --sign";
    #   gtv [] {
    #     git tag | lines | sort
    # }

    gunignore = "git update-index --no-assume-unchanged";
    gup = "git pull --rebase";
    gupv = "git pull --rebase --verbose";
    gupa = "git pull --rebase --autostash";
    gupav = "git pull --rebase --autostash --verbose";

    gwch = "git whatchanged -p --abbrev-commit --pretty=medium";

    gwt = "git worktree";
    gwta = "git worktree add";
    gwtls = "git worktree list";
    gwtmv = "git worktree move";
    gwtrm = "git worktree remove";

    gam = "git am";
    gamc = "git am --continue";
    gams = "git am --skip";
    gama = "git am --abort";
    gamscp = "git am --show-current-patch";
  };
  programs.git.aliases = {
    a = "add";
    aa = "add --all";
    ap = "add --path";
    b = "branch -vv";
    br = "branch";
    branches = "for-each-ref --sort=-committerdate --format=\"%(color:blue)%(authordate:relative)\t%(color:red)%(authorname)\t%(color:white)%(color:bold)%(refname:short)\" refs/remotes";
    c = "commit";
    ca = "commit --amend";
    changes = "diff --name-status -r";
    ci = "commit -v";
    cm = "commit --message";
    co = "checkout";
    cp = "cherry-pick";
    d = "diff";
    dc = "diff --cached";
    df = "diff --color --color-words --abbrev";
    dt = "difftool";
    dump = "cat-file -p";
    filelog = "log -u";
    fl = "log -u";
    h = "help";
    hide = "update-index --skip-worktree";
    hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
    l = "!git log --graph --pretty='tformat:%C(yellow)%h{%C(green)%ar{%C(bold blue)%an{%C(red)%d%C(reset) %s' $* | column -t -s '{' | less -FXRS";
    la = "!git list-aliases";
    lg = "log --graph --pretty=format:'%Cred%h%Creset %an -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
    lh = "! git ls-files -v | grep '^S'";
    list-aliases = "!git config -l | grep alias | cut -c 7-";
    ll = "log --pretty=format:%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn] --decorate --numstat";
    lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
    lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
    p = "push";
    pf = "push --force-with-lease";
    pnv = "push --no-verify";
    ra = "log --graph --abbrev-commit --date=relative -20 --all --pretty='format:%C(yellow)%h%Creset -%C(red)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'";
    rh = "reset --hard";
    s = "status --short --branch";
    stl = "stash list";
    stp = "stash pop";
    type = "cat-file -t";
    undo = "reset --soft HEAD^";
    unhide = "update-index --no-skip-worktree";
    unhideall = "!git ls-files -v | grep '^h' | sed -e 's/h //g' | xargs git unhide";
    up = "pull --rebase";
  };
}
