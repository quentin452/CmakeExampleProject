@echo off

REM Définir le répertoire de travail
set SHADER_DIR=%~dp0

REM Définir le répertoire des fichiers compilés
set COMPILED_DIR=%SHADER_DIR%

REM Créer le répertoire des fichiers compilés s'il n'existe pas
if not exist "%COMPILED_DIR%" mkdir "%COMPILED_DIR%"

REM Supprimer les fichiers .spv existants
del /Q "%COMPILED_DIR%\*.spv"

REM Compiler les shaders
REM glslc "%SHADER_DIR%\sky_shader.vert" -o "%COMPILED_DIR%\sky_vertex.spv"
REM glslc "%SHADER_DIR%\sky_shader.frag" -o "%COMPILED_DIR%\sky_fragment.spv"
REM glslc "%SHADER_DIR%\shader.vert" -o "%COMPILED_DIR%\vertex.spv"
REM glslc "%SHADER_DIR%\shader.frag" -o "%COMPILED_DIR%\fragment.spv"
REM glslc "%SHADER_DIR%\simple_shader.vert" -o "%COMPILED_DIR%\simple_shader.vert.spv"
REM glslc "%SHADER_DIR%\simple_shader.frag" -o "%COMPILED_DIR%\simple_shader.frag.spv"
REM glslc "%SHADER_DIR%\point_light.vert" -o "%COMPILED_DIR%\point_light.vert.spv"
REM glslc "%SHADER_DIR%\point_light.frag" -o "%COMPILED_DIR%\point_light.frag.spv"

REM Indiquer la fin de la compilation
echo Compilation des shaders terminée.
PAUSE
