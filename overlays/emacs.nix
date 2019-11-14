# vim: set ts=2 sts=2 sw=2 et :
self: super:
{ emacs = super.emacs.override
    { withGTK2 = false; withGTK3 = false; withX = true; };
}
