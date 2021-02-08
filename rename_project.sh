#!/bin/sh

if [ $# -eq 0 ]
then
    echo "You have to provide all arguments : $> sh rename_project.sh <oldName> <newName>"
    exit 1;
fi

refPath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo "Base path: $refPath"

oldName="$1"
echo "Old name: $oldName"
newName="$2"
echo "New name: $newName"
oldNamespace="$( echo $oldName | sed 's/./\L&/g' | sed 's/ //g' )"
echo "Old namespace: $oldNamespace"
newNamespace="$( echo $newName | sed 's/./\L&/g' | sed 's/ //g' )"
echo "New namespace: $newNamespace"

if [ ! -f "$refPath/game/${oldName}.csproj" ]
then
    echo "The old name you provided is not the current name. Note that it is case sensitive. If it is your first run, the base name is most likely 'Template'."
    exit 1;
fi

# change csproj file name
mv "$refPath/game/${oldName}.csproj" "$refPath/game/${newName}.csproj"

# update csproj name & file reference in sln file
sed -i "s/\"${oldName}\"/\"${newName}\"/" "$refPath/game/${oldName}.sln"
sed -i "s/\"${oldName}.csproj\"/\"${newName}.csproj\"/" "$refPath/game/${oldName}.sln"

# change sln file name
mv "$refPath/game/${oldName}.sln" "$refPath/game/${newName}.sln"

# change project name in project.godot
sed -i "s/config\/name=\"${oldName}\"/config\/name=\"${newName}\"/" "$refPath/game/project.godot"

# update base namespace and csproj file reference in Tests.csproj file
[ -f "$refPath/tests/Tests.csproj" ] && sed -i "s/${oldName}.csproj/${newName}.csproj/" "$refPath/tests/Tests.csproj"
[ -f "$refPath/tests/Tests.csproj" ] && sed -i "s/<RootNamespace>${oldNamespace}/<RootNamespace>${newNamespace}/" "$refPath/tests/Tests.csproj"

# update namespace on dummy tests
[ -f "$refPath/tests/godot/DummyGodotTest.cs" ] && sed -i "s/namespace ${oldNamespace}/namespace ${newNamespace}/" "$refPath/tests/godot/DummyGodotTest.cs"
[ -f "$refPath/tests/standard/DummyStandardTest.cs" ] && sed -i "s/namespace ${oldNamespace}/namespace ${newNamespace}/" "$refPath/tests/standard/DummyStandardTest.cs"

# Update namespace in the makefile
[ -f "$refPath/Makefile" ] && sed -i "s/standard_tests_namespace = ${oldNamespace}/standard_tests_namespace = ${newNamespace}/" "$refPath/Makefile"

# update the name on release workflow
[ -f "$refPath/.github/workflows/release.yml" ] && sed -i "s/EXPORT_NAME: \"Game\"/EXPORT_NAME: \"${newName}\"/" "$refPath/.github/workflows/release.yml"
[ -f "$refPath/.github/workflows/release.yml" ] && sed -i "s/EXPORT_NAME: \"${oldName}\"/EXPORT_NAME: \"${newName}\"/" "$refPath/.github/workflows/release.yml"

# Update the namespace on the test workflow
[ -f "$refPath/.github/workflows/run-tests.yml" ] && sed -i "s/STANDARD_TESTS_NAMESPACE: ${oldNamespace}/STANDARD_TESTS_NAMESPACE: ${newNamespace}/" "$refPath/.github/workflows/run-tests.yml"

echo "Re-building solution"
msbuild -target:Build -property:Configuration=Debug ./game

echo "Done."
