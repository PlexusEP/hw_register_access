# Code Styling

## Clang-Format

This template project leverages clangd (which embeds clang-format) to auto-format source code.  VS Code automatically formats any source code during save.  Project teams may adjust the clang-format configuration via the `clang-format` file using styles, such as Google or LLVM.  To disable automatic formatting, change `.vscode/settings.json`, `editor.formatOnSave` value to `false`.

### Alternative: Uncrustify

Uncrustify is a potential alternative to Clang-Format as an automated code styling tool.  For more information about Uncrustify, see [this page](./unlisted/uncrustify.md).