# Godot mono 3.2.3 project template

You can use it as a template to start a new Godot mono project.

It provides a configured project with Godot-mono and XUnit (with [GodotXUnit](https://github.com/fledware/GodotXUnit)), and configured github actions to run thoses tests and export the project.

## Warning
`GodotXunit` has been imported as a submodule to make it more easy to update and get the exact version that you want. But it comes with a few constraints.
- First, it is mounted in the `addons` directory of your game through a symbolic link, which means it won't work on Windows but the install process will tell you how to make it work.
- The other problem coming with the symlink is that it the project has some difficulties finding the `GodotSharp.dll` binary: you'll have to install it.

For theses reasons, here's the install process.

## Install

### Linux or MacOS
Good news is, if you're on a Linux or Mac system, this is pretty painless: just after checking out, you'll just have to execute the single command `make install` and you're done.

### Windows
If you're on Windows, here are the tasks you'll have to perform:

1. Install the submodule: `git submodule update --init`
2. Install the nuget dependencies: `nuget restore ./game`
3. Create the symlink into **.submodules/GodotXUNit/.mono** pointing to **game/.mono**: `mklink /D "..\..\game\.mono" ".\.submodules\GodotXUnit\.mono"`
3. Replace the symlink into **game/addons/GodotXUNit** pointing to **.submodules/GodotXUnit/addons/GodotXUnit**: `del /f ".\game\addons\GodotXUnit" && mklink /D ".\.submodules\GodotXUnit\addons\GodotXUnit" ".\game\addons\GodotXUnit" && git update-index --assume-unchanged ".\game\addons\GodotXUnit"`
4. Build: `godot --path ./game --build-solutions --quit`
5. (Optional) Get the console test runner: `nuget install xunit.runner.console -Version 2.4.1 -OutputDirectory %HOMEPATH%/.nuget/packages`

## Content

To make it more manageable, all your game files are located in the `game` directory, and all tests are located in the `tests` directory. The tests are declared as a separate project imported by the solution and have a dependency to the game project. (You'll also see the `GodotXUnitApi` project in your solution, but can ignore it, as you'll never have to touch what's inside - hope it'll be exported as a dll in the future, making the install process a bit more simple).

### Tests

XUnit can run any test, but you have te bo in a Godot context to be able tu instantiate Godot files (that's why we need the GodotXUnit extension).

If you want to run some test on non Godot derived classes, you won't need to run it from the GodotXUnit addon, and use your usual test runner.

You can use `[Fact]` or `[GodotFact]` for your tests, just note that `[GodotFact]` has some very useful options (see https://github.com/fledware/GodotXUnit/blob/master/README.md).

To make it simple, by default, there's a namespace for **godot tests** (`template.tests.godot`) and a namespace for **standard tests** (`template.tests.standard`) who don't need to run in a Godot context.

But remember your `[GodotFact]`s will be detected but won't be able to run if you test Godot objects in it. So be very careful where you put your tests, as only the `standard` tests will be able tu run.


#### Godot
You'll be able to run every XUnit test from the Godot editor (GodotXUnit tab) with the `Run All Tests` button.

#### IDE
Select the appropriate namespace for standard tests in the testing menu and run for the whole namespace. If you select Godot tests, they'll fail.

### Command line
You can run **standard** tests:
- Linux & Mac: `make standard-test`
- Windows: `mono %HOMEPATH%/.nuget/packages/xunit.runner.console/2.4.1/tools/net472/xunit.console.exe ./tests/bin/Debug/net472/Tests.dll -namespace template.test.standard` (if you renamed your project, `template` might have been replaced by a new name)

You can run **godot** tests:
- Linux & Mac: `make godot-test`
- Windows: `godot --path ./game res://addons/GodotXUnit/runner/GodotTestRunnerScene.tscn`

Just remember you might want to build beforehand (`make quick-build` or `msbuild -target:Build -property:Configuration=Debug ./game`).

### CI

It installs two CI workflows:
- `run-tests`: run all tests at **each push**
- `release`: create a release for windows/mac/linux/html when a **new tag** is pushed

### General

If you don't intend using tests, you can just delete the `tests` directory, remove the Tests and GodotXUnit projects from the solution, delete the `game/addons` directory and `.github/workflows/run-tests.yml` file (but you should also reconsider your life choices).

If you delete the default scene (`game/DefaultScene.tscn` & `game/DefaultScene.cs`), don't forget to redefine a new main scene.

## Renaming the project

If you plan to rename the project (and you should) try doing it very early in the development process and use `rename_project.sh` to do so.
You'll be able to use it afterwards but you might have a few problems with your namespaces (but it shoudn't be a problem) or other files that might reference the project name (if you have created them). In this case, modify the script for your needs.

### Usage
`sh rename_project.sh <old name> <new name>`

On your first run, the `old name` must be set to `Template`.

You can use spaces in your name as they're well supported by Godot and Visual Studio. Note that when generating the new namespace, it will remove all spaces and use lowercase.

If you plan to use the command on MacOS, consider installing `gnu-sed` as the `sed` version pre-installed on MacOS is not compatible and will result in error. To install it use `brew install gnu-sed` and don't forget to add `gnubin` to your path or it will continue using the old version (see what brew tells you during install). If you don't want to add it to your path, replace `sed` by `gsed`.

### Performed tasks
`rename_project.sh` will rename the following files:
- `game/Template.sln`
- `game/Template.csProj`

It will also update references:
- `game/Template.sln`: it will update the name of the project and path to the `.csproj` file
- `game/project.godot`: it will update the name of the project
- `tests/Tests.csproj`: it will update the reference to the game project and change the default namespace
- `tests/DummyTest.cs`: it will change the namespace (note that this is the only test file it will change, if you have others feel free to modify the script)
- `.github/workflows/release.yml`: it will update the name of the project for the export file

## Known Issues (and solutions)
While running tests, at build step, you can get some errors.
- Sometimes, the `godot` command won't quit after building the solution and I haven't been able to know why. If this happens to you, it will prevent the step to complete and cost a lot of action time. To prevent it, an option has been set in `.github/workflows/run-tests.yml#32` (sorry, I can't put it in a variable) that will allow your step to finish after 1 minute (change the value if you want to wait more) and will go to the `Tests` step (which will fail if your build step failed, but will run if that was just a problem with the `godot` executable).

Let me know if you find any other issue.
