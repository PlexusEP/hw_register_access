# Mermaid as a Potential Alternative to PlantUML

## How to Incorporate

The following sections provide snippets of code that provide loose guidance for how to incorporate Clang-Tidy into the C++ Project Template.

### Install Into Docker

.../tools/docker/build-image/Dockerfile

Remove the line:
```
plantuml=1:1.2020.2+ds-1 \
```

.../tools/docker/build-image/mkdocs_requirements.txt

Replace the lines:
```
plantuml==0.3.0
plantuml-markdown==3.5.1
```
With:
```
mkdocs-mermaid2-plugin==0.6.0
```

### Incorporate Into MkDocs Configuration

.../docs/common.yml

Remove the following line from the markdown extenstions:
```
  - plantuml_markdown
```
Add the following lines to the Plugin section:
```
  - mermaid2:
      version: 8.9.2
```