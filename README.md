GitHub for [Codea](http://twolivesleft.com/Codea/)
==============================

This is an implementation of the GitHub API for codea. Although only a small subset of the API is implemented, this tool is incredibly useful.

1. Upload Codea projects to GitHub
2. Download GitHub repos to Codea
3. Compare the Codea project to the GitHub repo and see individual line differences
4. Upload code changes to GitHub
5. Compare to previous revisions

This project requires you to break out of the Codea sandbox, and uses many unsupported Codea features which could easily break in future versions of Codea.
This tool is targeted at the expert Codea user. If you're new to [Codea](http://twolivesleft.com/Codea/), familiarize yourself with it first, it's a great app!

To reiterate: this tool is not supported by Two Lives Left

Passwords - READ THIS
------------------------------

I've only implemented what GitHub calls 'Basic Authentication'. 
This means that your username and password are sent in clear text and can be easily stolen.

I don't feel comfortable with that, but it was much simpler than implementing OAuth authentication.
Before using this tool I changed my own password to something I don't care about if it gets stolen. I suggest you do the same.

Note that passwords are only required for making commits. 

How to Install
----------------------------

1. [Download] (https://github.com/ruilov/GitClient-Release/downloads) this repo
2. Create a project called `GitHub` in Codea (call it whatever you want, I don't care)
3. Close Codea: double click the Home bottom, press the Codea icon for a few seconds, and then close it. 
4. Connect your iPad to your computer. I do this in Windows using [iExplorer] (http://www.macroplant.com/iexplorer/)
5. In your iPad, navigate to `Apps/com.twolivesleft.Codify/Codea.app` and copy the file [LuaSandbox.lua](https://github.com/ruilov/GitClient-Release/blob/master/LuaSandbox.lua) from the repo into this directory
6. In your iPad, navigate to `Apps/com.twolivesleft.Codify/Documents/GitHub` and copy the rest of the repo files in there

The Sandbox
---------------------------

The LuaSandbox.lua file removes all restrictions on what Codea programs can do. I needed to this to be able to read/write project contents from within Codea.

As a bonus, I've also included my implementation of the `import` function in the LuaSandbox file. 
You can now import a codea project from another project, making life much easier if you have libraries that you'd like to re-use in many Codea project. 


At the top of any Codea tab, just do `import("project name")`. This will execute all files of project name. 
Note that the import function never executes the same project twice, even if it's imported from multiple Codea tabs.

How to Use
-----------------------------

<b>Creating Projects and Repos</b>

Unfortunately I could not figure out how to create Codea projects programatically. Nor could I figure out how to create GitHub repos programatically either. 
I guess there's some order to the world.

To start using the tool, you first need to have a Codea project and a GitHub repo. The GitHub repo needs to contain at least one file (example: the README file),
otherwise the Codea tool will break. The mental model is one repo per project. 

<b> Users </b>

The start screen will ask for a GitHub username. The user doesn't have to be you - if you choose another user, you will be able to download their repos but obviously not be able to upload code without their password. There currently is no way to fork, do pull requests, etc.

<b> Connect a project to a repo</b>

In the second screen you need to enter the name of the Codea project and choose one of the repos. 
Once you've done this the start screen will show a quick access link for this project/repo pair so that you don't have to type the name of the project every time you run the tool.

<b> Revisions </b>

The next screen will show the latest few revisions of the repo. You will typically want to select the top one, which is the latest.

<b> File List </b>

The next screen will give your the optiosn to `Push to repo` and `Pull from repo` as well as a list of files. `Push to repo` uploads to GitHub and `Pull from repo` downloads to Codea.

<b> Diffs </b>

The list of files lets you explore differences between the version in Codea and in GitHub. 

1. Files that are in Codea but not in GitHub show as Added (BLUE)
2. Files that are in GitHub but not in Codea show as Removed (RED)
3. Files that are in both but with different contents show as Changed (YELLOW)

You can click on any file to see the differences between Codea and GitHub. Note the little arrows on the top right which let you navigate to the next or previous diff.

<b> Push / Pull <b>

The `Push to repo` and `Pull from repo` screens are very similar. They'll ask for your password, a commit message and show an OK button. 
You can also select only a subset of the files to push or pull. By default, all added+removed+changed files are selected.

A current limitation: you cannot delete files from the GitHub repo, even if they have been removed from the Codea project.

Contributing
-------------------------------

Only a very minimal set of the GitHub API is used. I implemented features that I found most useful, but my use case might not be the same as yours. 
If you'd like to add features, let me know. That would be super useful. 


Implementing repo file deletion is on my to-do, but may require re-working a bunch of the code. Also implementing OAuth authentication would be great.
