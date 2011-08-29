
Thank you for downloading the Path Finder SDK.  Included in the SDK are a few simple tutorials for writing Path Finder plugins, and lots of additional open source examples and frameworks.  It might seem a little overwhelming at first glance, but it's actually very simple.  The frameworks included are not required for writing plugins.  They are included so that you can compile the more complex examples.

// -----------------------------------
// Plugins
// -----------------------------------

To quickly get started writing plugins, you should look at the tutorials.  Inside the "Source" folder you will find two folders:

"MenuPluginTutorial":  This is an simple tutorial on how to write a menu plugin.  A menu plugin allows you to add a menu command to Path Finders commands menu. Look at the readme.txt file in this folder and follow the instructions.  The included XCode project and source files are the finished result of following those instructions.

"ModulePluginTutorial":  This is an simple tutorial on how to write a module plugin.  A module plugin is simply a view that you can include in Path Finders main browser window or drawers.  Look at the readme.txt file in this folder and follow the instructions.  The included XCode project and source files are the finished result of following those instructions.

After you learn how those plugins work, you can explore the Advanced Plugins.  These are the plugins that currently ship with Path Finder.  If you find a bug, please let me know!

// -----------------------------------
// Controlling Path Finder
// -----------------------------------

Also included in the SDK is a framework for controlling Path Finder from your application.  Take a look at the folder named "Path Finder Remote".  Inside is a simple sample application that will allow you to reveal files in Path Finder, and a bunch of other things.

// -----------------------------------
// Open source frameworks
// -----------------------------------

I included a few open source frameworks that contain code extensively used in Path Finder.  CocoatechCore, CocoatechFile, CocoatechStrings and iTerm.  Some of the more advanced plugins require this code, so it's included so you can compile and debug these examples.  If you write a plugin that uses these frameworks you can assume that they will be in Path Finders frameworks folder, so you don't have to worry about copying them yourself.

Not all the code in these frameworks is interesting or useful.  I needed to divide my code into frameworks for reusability and over time this was the result.  This code isn't well documented, but should be easy to read.  You can safely ignore it if you have no interest in using it. iTerm is a modified version of the official iTerm project hosted on sourceforge.  I use this in the TerminalModulePlugin.