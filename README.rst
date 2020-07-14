..   -*- mode: rst -*-

=============
Pipenvwrapper
=============

`Pipenvwrapper <https://github.com/Peibolvig/pipenvwrapper>`_ is a set wrapper
functions to Kenneth Reitz's `pipenv <http://pypi.python.org/pypi/pipenv>`_ tool.

Pipenvwrapper is heavily based on modifications and cherrypicking of Doug
Hellman's `virtualenvwrapper <http://www.doughellmann.com/projects/virtualenvwrapper/>`_
methods.

The wrapper functions include actions like creating projects and deleting
virtual environments

------------
Dependencies
------------

Only `pipenv
<http://pypi.python.org/pypi/pipenv>`_ is required

`pyenv <https://github.com/pyenv/pyenv>`_ is recommended to manage several python
versions in an easy way.

------------
Installation
------------
Just copy the *pipenvwrapper.sh* file in some accessible path and add
the next lines to your shell startup file (.bashrc, .profile, ...) to set the
location where the virtual environments should live, the location of your
development project directories and the sourcing of the *pipenvwrapper.sh* file

.. code:: bash

    export WORKON_HOME=$HOME/.virtualenvs
    export PROJECT_HOME=$HOME/Devel
    source /usr/local/bin/pipenvwrapper.sh

After editing it, reload the startup file (e.g.,
run ``/usr/bin/pipenwrapper.sh``)

---------------------
Pipenvwrapper methods
---------------------

The names inside square brackets correspond to the original virtualenvwrapper
function names.

To use the original virtualenvwrapper methods go to
`Using the virtualenvwrapper methods`_

Methods to use with non active virtualenv
-----------------------------------------

* **makeproject [mkproject]**: create a new project and its associated
  virtualenv in $PROJECT_HOME

* **useenv [workon]**: use specified virtualenv or list all of them available if
  none is provided

Methods to use with active virtualenv
-------------------------------------

* **gotoproject [cdproject]**: change directory to the active project one

* **gotovirtualenv [cdvirtualenv]**: change to the active virtualenv directory

* **getrequirements**: Echoes the list of all the requirements (including the
  dev ones) in a pip freeze way

Methods to use in any situation
-------------------------------

* **gotositepackages [cdsitepackages]**: change directory to the site-packages
  one

* **listvirtualenvs [lsvirtualenv]**: list virtualenvs available

* **pipenvwrapper**: show help message

* **removevirtualenv [rmvirtualenv]**: remove specified virtualenv


.. _`Using the virtualenvwrapper methods`:

-----------------------------------
Using the virtualenvwrapper methods
-----------------------------------
By default, pipenvwrapper uses its own function names to allow the coexistence
with virtualenvwrapper.

If you prefer pipenvwrapper to override virtualenvwrapper, you should set the
*PIPENVWRAPPER_USE_VIRTUALENVWRAPPER_FUNCTION_NAMES* environment variable in your shell startup
file. Any value other than empty will do.

.. code:: bash

    export PIPENVWRAPPER_USE_VIRTUALENVWRAPPER_FUNCTION_NAMES=1

.. note::

    Take into account that the really important thing is that the variable is
    set and has some value. It does not matter the value itself, so even if you
    set it as 0 or false it will switch on the original function names

----------------
Supported Shells
----------------

pipenvwrapper is a set of shell functions defined in Bourne shell compatible
syntax.

It has been tested under *bash* and Linux OS.

It may work with other shells like *ksh* and *zsh*, as the basecode
of virtualenvwrapper do so.

---------------
Python Versions
---------------

pipenvwrapper is tested under Python 3.5+.

--------------
Other projects
--------------

If pipenvwrapper is not what you are looking for, maybe this other projects with
different approaches are a better fit for your workflow.

* `pew <https://github.com/berdario/pew>`_

* `pipes <https://github.com/gtalarico/pipenv-pipes>`_

-------------
Shell Aliases
-------------

Since pipenvwrapper is largely a shell script, it uses shell commands for a lot
of its actions.  If your environment makes heavy use of shell aliases or other
customizations, you may encounter issues.


-------
License
-------

Copyright 2018 Pablo Vázquez Rodríguez

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.
