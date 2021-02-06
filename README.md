# Godot mono 3.2.3 project template

You can use it as a template to start a new Godot mono project.

It is bundled with `XUnit` and `WAT` so that you can test the way you want.

It also provides CI workflows for github (with Github Actions).

**You'll have to open the project in Godot first, so it can setup the project, before opening the solution in Visual Studio. It won't compile until you do.** (Godot will add the Godot dlls in the `.mono` directory of `game`, which are mandatory to build the solution).

## General information

To make it more manageable, all your game files are located in the `game` directory, and all XUnit tests are located in the `tests` directory. The XUnit tests are declared as a separate project imported by the solution and have a dependency to the game project. Sadly, the same can't be done for WAT tests because it needs the Godot context to run (but you'll be able to test your Godot objects).

If you delete the default scene (`game/DefaultScene.tscn` & `game/DefaultScene.cs`), don't forget to redefine a new main scene.

`WAT` is imported as a submodule in the `.submodules` directory and the addon is then added to the `addons` directory in `game` using a symbolic link. (As it is not the default version, but the mono version, it is not part af the asset AssetLib). Note that it targets the main version, which can be an issue: don't forget to update it.

## Github actions workflows

It installs two CI workflows:
- `run-tests`: run tests at **each push**
- `release`: create a release for windows/mac/linux/html when a **new tag** is pushed

### Run tests worflow

It will run both XUnit and WAT tests.

If you don't intend using XUnit tests, you can just delete the `tests` project in the solution, and its directory and remove the step in the `.github/workflows/run-tests.yml` file.

If you don't intend using WAT tests, you can just delete the `tests` directory inside of `games`, deactivate and delete WAT from the addons and remove the step in the `.github/workflows/run-tests.yml` file. You might also want to delete the submodule for WAT, if you do, don't forget to remove any line saying `submodules: true` in `.github/workflows/run-tests.yml`, or make it `false`.

If you don't want any tests at all, just delete `.github/workflows/run-tests.yml` and follow the previous steps (but you should definitely reconsider).

### Release

It will release for every computer platform.

If you provide itch.io credentials, it will upload it using `Butler` and tag it according to the git tag. If you don't provide itch.io credentials, it ignores the step.

If you hav custom icons, the windows edge case with rcedit is already taken care of (you'll still have to do it on your own machine if you intend on exporting using it and not the release workflow).

## Renaming the project

If you plan to rename the project (and you should) try doing it very early in the development process and use `rename_project.sh` to do so.
You'll be able to use it afterwards but you might have a few problems with your tests namespace (but it shoudn't be a problem) or other files that might reference the project name (if you have created them). In this cas, modify the script for your needs.

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
- If you're using it on windows, the symbolic link that imports WAT addon won't work, but you can use this trick: https://stackoverflow.com/questions/5917249/git-symlinks-in-windows
- Sometimes, the `godot` command won't quit after building the solution and I haven't been able to know why. If this happens to you, it will prevent the step to complete and cost a lot of action time. To prevent it, an option has been set in `.github/workflows/run-tests.yml#32` (sorry, I can't put it in a variable) that will allow your step to finish after 1 minute (change the value if you want to wait more) and will go to the `Tests` step (which will fail if your build step failed, but will run if that was just a problem with the `godot` executable).
- When running WAT tests, it sometimes modifies the files of the submodule. If that happens, at the root of the repository, use `make clean`: it will restore the WAT-mono repository to its previous state.

Let me know if you find any other issue.
