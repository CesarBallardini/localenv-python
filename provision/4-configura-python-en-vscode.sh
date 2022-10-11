#!/usr/bin/env bash
export PROJECT_DIR=/vagrant/proyecto

cd "${PROJECT_DIR}"


##
# instala extensiones necesarias
#
code --install-extension ms-python.python
code --install-extension njpwerner.autodocstring
code --install-extension hbenl.vscode-test-explorer
code --install-extension LittleFoxTeam.vscode-python-test-adapter
code --install-extension markis.code-coverage
code --install-extension vscode-icons-team.vscode-icons


[ -d .vscode ] || mkdir .vscode/
cat | tee -a .vscode/settings.json <<'EOF'
{
    "python.testing.pytestArgs": [
        "./src/domain/tests",
    ],
    "python.testing.unittestEnabled": false,
    "python.testing.pytestEnabled": true,
    "python.defaultInterpreterPath": "venv/bin/python",

    // Editor settings
    "files.autoSave": "onFocusChange",
    "explorer.confirmDragAndDrop": false,
    "explorer.confirmDelete": false,

    // Python linting settings
    "python.linting.enabled": true,
    "python.linting.lintOnSave": true,
    "python.linting.flake8Enabled": true,
    "python.linting.pylintEnabled": true,
    "python.linting.mypyEnabled": true,
    "python.formatting.provider": "autopep8",

    // Python execution settings
    "python.languageServer": "Pylance",
    //"python.showStartPage": false,
    "autoDocstring.docstringFormat": "google",
    "autoDocstring.generateDocstringOnEnter": true,
    "autoDocstring.quoteStyle": "\"\"\"",


    "python.formatting.autopep8Args": [
        "--max-line-length=110",  // 120 ng code
    ],
    "python.linting.flake8Args": [ // https://pep8.redthedocs.io/en/latest/intro.html#error-codes
        "--max-line-length=110",
        "--ignore=W293,E302,E266,W391,E402,E226,W291,E116,E502,W503",
    ],
    // "python.dataScience.ignoreVscodeTheme": true,


    "window.title": "${activeEditorLong}", // Show the path to the opened file in the window name
    "telemetry.telemetryLevel": "off",

    "workbench.colorTheme": "Visual Studio Light",
    "workbench.iconTheme": "vscode-icons",

    "debug.console.fontSize": 16, // 14

    "diffEditor.wordWrap": "on",
    "diffEditor.ignoreTrimWhitespace": false,


    "editor.bracketPairColorization.enabled": true,
    "editor.fontSize": 16, // 14
    "editor.rulers": [
        110
    ],
    "editor.renderWhitespace": "all",
    "editor.renderControlCharacters": true,
    "editor.formatOnPaste": true,
    "editor.suggestSelection": "first",
    "editor.snippetSuggestions": "top",
    "editor.quickSuggestionsDelay": 0,
    "editor.quickSuggestions": {
        "strings": true,
        "comments": true,
    },
    "editor.formatOnSaveMode": "modifications",
    "editor.minimap.enabled": false,

    "terminal.integrated.fontSize": 16,  // 14
    "terminal.integrated.cursorStyle": "block",
    "terminal.integrated.cursorBlinking": true,
    "terminal.integrated.scrollback": 10000,

    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "files.trimFinalNewlines": true,
    "files.exclude": {
        "**/.DS_Store": false,
        "**/.git": false,
        "**/.hg": false,
        "**/.svn": false,
        "**/CVS": false,
    },
    "search.exclude": {
        "**/.git": true,
    },
}
EOF

# versión del vscode:
code --version

# lista las extensiones instaladas
code --list-extensions

