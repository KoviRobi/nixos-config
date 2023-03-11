export-env {
  let-env dirs = []

  def-env dirs [
    --clear (-c) # Clear the directory stack
  ] {
    if $clear {
      let-env dirs = [ $env.PWD ]
    } else {
      $env.dirs | enumerate | reverse
    }
  }

  def-env popd [
    number: int = 1 # Entry to go to, see the indices in `dirs`
  ] {
    let dest = ($env.dirs | get $number)
    # Drop also the target directory, it gets re-added, though only if we
    # actually change directory hence the 0 special case
    let-env dirs = ($env.dirs | skip (if $number == 0 { 0 } else { $number + 1 }))
    cd $dest
  }

  let-env config = ($env.config | update hooks.env_change.PWD {|curr| $curr.hooks.env_change.PWD ++ [
    {|before, after| let-env dirs = ([$after] ++ $env.dirs )}
  ]})
}
