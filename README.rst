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
build the ``gbenson/mediawiki`` container image.  After testing, the
container's document root is extracted into the ``staging`` directory
and then deployed to the live site using git.  To update the site:

1. Download any new files you need into ``sources``.
2. Edit ``Dockerfile`` with any changes you need.
3. Either build the container image locally
   (``docker build --tag=gbenson/mediawiki .``), or just push a
   ``vX.Y.Z-R`` tag to GitHub and let the CI workflow build the
   image and push it to Docker Hub.
4. Run ``./push-to-staging`` to copy everything into ``staging``.
5. ``cd`` into ``staging``, use ``git diff`` to make sure everything's
   as you want it.  Go back and make changes if necessary.
6. Commit your changes, then ``git push`` them.  The ``post-receive``
   hook on the other end will deploy what you've pushed.
7. ``cd`` out of ``staging``, and commit your changes there.
