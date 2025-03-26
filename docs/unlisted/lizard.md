# Lizard

Lizard is a cyclomatic complexity analyzer for many languages; it focuses on how complex the code 'looks'.  For details about the purpose, limitations, and command-line options of Lizard, see the [PyPI page](https://pypi.org/project/lizard/1.17.10/).

## How to Use

### Option 1: `lizard_report.sh` script

Run the `lizard_report.sh` script from the root of the project. This will query the `lizard_exclude.sh` file for file patterns to ignore. Below is its usage.
`lizard_report.sh <REPORT_DIR> [EXCLUDE_ARGS...]`

* `<REPORT_DIR>`: the directory in which the report will be generated.
* `[EXCLUDE_ARGS...]`: patterns of files to exclude. See the description of the `-x` flag on the [PyPI page](https://pypi.org/project/lizard/1.17.10/) for more details.

### Option 2: VS Code Lizard tasks

Alternatively, the following VS Code tasks can be used to run Lizard:

* `Lizard: Single File`: Run Lizard on the file currently focused in the editor.
* `Lizard: Generate Report`: Generate a Lizard complexity analysis report on all source files in the project.
* `Lizard: Serve Report on localhost:8002`: Generate and serve the Lizard report within VS Code. If a non-HTML report is generated, the serving functionality may not work.

## Output
The default output from the script is HTML, and can be found at `build/lizard_report/index.html`.  The output consists of a report table documenting the [CCN](https://en.wikipedia.org/wiki/Cyclomatic_complexity#Definition), argument count, NLOC (number of lines of code), and token count of each function found.  A sample report for the default project can be found in this folder as `sample_lizard_report.html`.

## Modification
The format of the output can be changed to CSV, XML, or plain text via different options in the script. The warning limits of the script can be changed with `-T` parameters, and the number of jobs (recommended for larger projects) can be changed with the `-t` parameter.
**NOTE:** Due to a limitation of Lizard, using the `-t` flag in conjunction with the `-x` flag may cause lizard to hang.

## Validation
Lizard has not been validated because code complexity is not typically a metric specified in the code standards section of an Software Verification Plan. If code complexity is a part of the published code standard to meet unit verification plans, this tool must be validated as NPS.