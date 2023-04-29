Hive
====

How to operate the website known as Hive.

Initial setup
-------------

Add the deployment site to your ``~/.ssh/config``::

  cat >>~/.ssh/config <<EOF
  Host hivesite
  Hostname (you know it)
  User (you know it)
  ForwardX11 no
  ForwardAgent no
  Compression yes
  EOF

Recursively clone the repo::

  git clone --recursive git@github.com:gbenson/hivesite.git
  cd hivesite

The ``staging`` subdirectory now contains a local copy of what's on
the live site.


Updating the the site
---------------------

The ``sources`` directory contains the tarballs that were used to
build the ``staging`` directory.  To update the site:

1. Download any new files you need into ``sources``.
2. Edit ``push-to-staging`` with any changes you need.
3. Run ``./push-to-staging`` to rebuild everything in ``staging``.
4. ``cd`` into ``staging``, use ``git diff`` to make sure everything's
   as you want it.  Go back and make changes if necessary.
5. Commit your changes, then ``git push`` them.  The ``post-receive``
   hook on the other end will deploy what you've pushed.
6. ``cd`` out of ``staging``, and commit your changes there.
