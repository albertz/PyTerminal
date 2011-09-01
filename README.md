PyTerminal
==========

A MacOSX framework, based on [iTerm](http://iterm.sourceforge.net/), which provides a Terminal window for an interactive Python environment.

Python runs in the same process as the application which uses the framework. This makes projects like [Pyjector](https://github.com/albertz/Pyjector) possible.

Demo
----

![screenshot](https://github.com/albertz/PyTerminal/raw/master/Screenshots/Shot1.png)

Implementation details
----------------------

It links against the MacOSX `Python.framework`.

For each terminal tab:

* It uses `openpty` to create new virtual tty,
* it creates a new Python interpreter instance
* and it sets its `sys.stdin`, `sys.stdout`, `sys.stderr` accordingly.

PyTerminal also provides its own readline Python module implementation based on [python-readline](https://github.com/ludwigschwardt/python-readline) because of multithreading issues. The issues in the readline library itself cannot be resolved that easily but at least it automatically uses a fallback now and doesn't wait on a lock (this resulted in very strange behavior).

In the future, some of the interactive consoles which are provides by [IPython](http://ipython.org/), e.g. the [Qt console](http://ipython.org/ipython-doc/rel-0.11/interactive/qtconsole.html#qtconsole), might be good alternatives.

-- Albert Zeyer, <http://www.az2000.de>
