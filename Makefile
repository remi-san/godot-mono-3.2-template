
.PHONY: init

nuget_dir = ~/.nuget/packages
runner = xunit.runner.console
runner_version = 2.4.1
runner_bin = xunit.console.exe
framework_version = net472
standard_tests_namespace = template.test.standard

init-submodules:
	git submodule update --init

link-dlls:
	-ln -s ../../game/.mono ./.submodules/GodotXUnit/.mono

nuget-restore:
	nuget restore ./game

quick-build:
	msbuild -target:Build -property:Configuration=Debug ./game

build:
	godot --path ./game --build-solutions --quit

install-test-runner:
	nuget install $(runner) -Version $(runner_version) -OutputDirectory $(nuget_dir)

install: init-submodules nuget-restore link-dlls build install-test-runner

standard-test:
	mono $(nuget_dir)/$(runner)/$(runner_version)/tools/$(framework_version)/$(runner_bin) ./tests/bin/Debug/$(framework_version)/Tests.dll -namespace $(standard_tests_namespace)

godot-test:
	godot --path ./game res://addons/GodotXUnit/runner/GodotTestRunnerScene.tscn

test: standard-test godot-test
