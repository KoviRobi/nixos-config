# vim: set ts=2 sts=2 sw=2 et :
self: super:
{ myEmacs = self.emacs.override
    { withGTK2 = false; withGTK3 = false; withX = true; };
}
