# PC-lint Plus Configuration

## Target Audience
EP is the primary audience for this documentation, since it is recommended that they configure PC-lint Plus on project teams' behalf.

## Concept and Motivation
Much of the input necessary for static analysis is the same as what is used for software compilation.  Additionally, users are becoming accustomed to CMake build targets as the "scope" of what they're working on.  Due to these considerations, it made sense to wrap PC-lint Plus static analysis configuration within CMake.  Although the implementation is relatively involved and extends beyond CMake to include Bash scripting as well, the global configuration files and target-specific CMake API are straightforward.

## Configuration

### Global Configuration Files
Developers can populate files to specify portions of PC-lint Plus configuration that are global and apply to all "registered" targets.  These files are contained within `tools/pclp/global_configuration` and their intended use are detailed below.

* `global_exclude_patterns` - used to specify exclude patterns that apply to all registered targets during their PC-lint Plus compiler configuration
* `global_libraries` - used to specify `+libm` and `+libdir` options that apply to all registered targets
* `global_options` - used to specify PC-lint plus options that apply to all registered targets

### Target-Specific CMake API
This API is defined in `tools/cmake/pclp.cmake` and is summarized below.

```
pclp_single_target_configuration(<TARGET>
    [COMPILER_CFG_GENERIC_OPTIONS <option>...]
    [COMPILER_CFG_C_OPTIONS <option>...]
    [COMPILER_CFG_CPP_OPTIONS <option>...]
    [PROJECT_CFG_INCLUDE_PATTERNS <pattern>...]
    [PROJECT_CFG_EXCLUDE_PATTERNS <pattern>...]
    [LIBRARY_DIRS <directory>...]
    [LIBRARY_TARGETS <target>...]
    [LIBRARY_OPTIONS_FILES <PCLP library file>...]
    [ANALYSIS_OPTIONS <PCLP option>...]
    [ANALYSIS_OPTIONS_FILES] <PCLP options file>...)
```
Call this function within an individual target's CMakeLists.txt to "register" it for analysis with PC-lint Plus, and configure it.  
  
*Required Arguments*

* `TARGET` - the target being registered and configured for PC-lint Plus analysis

*Options*

* `COMPILER_CFG_GENERIC_OPTIONS` - non-language-specific compiler options to pass to pclp_config.py during compiler configuration
* `COMPILER_CFG_C_OPTIONS` - C compiler options to pass to pclp_config.py during compiler configuration
* `COMPILER_CFG_CPP_OPTIONS` - C++ compiler options to pass to pclp_config.py during compiler configuration
* `PROJECT_CFG_INCLUDE_PATTERNS` - include patterns to pass to pclp_config.py during project configuration
* `PROJECT_CFG_EXCLUDE_PATTERNS` - exclude patterns to pass to pclp_config.py during project configuration
* `LIBRARY_DIRS` - list of directories that PCLP should assume contain library modules and library headers
* `LIBRARY_TARGETS` - list of targets that PCLP should treat as PCLP libraries
* `LIBRARY_OPTIONS_FILES` - list of .lnt files that presumably include `+libm` and `+libdir` options
* `ANALYSIS_OPTIONS` - list of PCLP options (e.g., `-e`)
* `ANALYSIS_OPTIONS_FILES` - list of .lnt files that presumably include PCLP options

```
pclp_complete_configuration_after_targets_defined()
```
Call this function once after all targets have been defined to complete CMake-target-based PC-lint Plus configuration.  This is typically invoked at the end of the top-level CMakeLists.txt file.  There are no arguments for this function.

## Implementation

```plantuml format="png"
scale 1.0
title Upfront Setup
start
group Provide PCLP Configuration Inputs
    :EP defines global PCLP
    configuration inputs via files;
    :EP registers PCLP analysis targets
    and provides their inputs to
    PCLP configuration via CMake;
end group
stop
```

```plantuml format="png"
scale 1.0
title On-Demand Analysis
start
:Developer hits `Analyze` button
or saves C/C++ source file;
:VS Code task invokes `analyze.sh`;
group Configure
    group CMake Configuration
        :CMake configure target to
        produce target PCLP
        configuration input files;
        if (`all` target?) then (yes)
            group foreach target comprising `all`
                :CMake configure target to
                produce target PCLP
                configuration input files;
            endgroup
        else (no)
        endif
    end group

    note right
        Performed by functions
        defined within CMake.
    end note

    note right
        For more details related
        to CMake Configuration see
        additional diagram, below.
    end note

    group PCLP Configuration
        if (`all` target?) then (yes)
            group foreach target comprising `all`
                :generate PCLP compiler
                configuration for target;
                :generate PCLP project
                configuration for target;
            endgroup
        else (no)
            :generate PCLP compiler
            configuration for target;
            :generate PCLP project
            configuration for target;
        endif
    end group

    note right
        Performed by
        Bash scripts.
    end note

end group
group Analyze
    if (`all` target?) then (yes)
        group foreach target comprising `all`
            :Invoke PCLP, pointing it to the
            global configuration and the
            generated target configuration;
        endgroup
    else (no)
        :Invoke PCLP, pointing it to the
        global configuration and the
        generated target configuration;
    endif
end group

note right
    Performed by
    Bash scripts
    and PCLP.
end note
stop
```

Supporting the use of generator expressions complicates the CMake Configuration portion of the above diagram.  PCLP active target CMake Configuration is broken into multiple stages since some of the information PCLP needs depends on target properties which may contain generator expressions that need to be "resolved."  Here, "resolved" means any generator expressions that exist within relevant target properties need to be evaluated.  For example, `$<$<CONFIG:DEBUG>:foo>` as a LINK_LIBRARY should resolve to `foo` when the DEBUG configuration is active.  Otherwise, it should resolve to an empty string.

Unfortunately, generator expression evaluation only occurs during the CMake generation phase, which occurs automatically after and separate from CMake configuration.  And in this case, there are multiple steps during PCLP active target CMake Configuration where resolved target properties are required, some of which depend on previously resolved target properties.  The result is that PCLP active target CMake Configuration is split across multiple invocations of CMake so that target properties are resolved by the time they are needed, so that they can be used to resolve other target properties, etc.  Each grouping of CMake invocations is called a "stage."  There are currently four stages comprising PCLP active target CMake Configuration.

```plantuml format="png"
scale 1.0
title CMake Configuration Stages
start
:Active analysis target configuration 
is recorded to file, but only
that which does not require
evaluation of generator expressions.;
note right: Stage 0
group Stage 1 Loop
    :Resolve active analysis target and
    all recursive dependencies.;
end group
group Stage 2 Loop
    :Resolve active analysis target's library targets
    and their recursive dependencies, and record
    cumulative list of library source directories and
    library public include directories.;
end group
group Stage 3 Loop
    :Generate active-analysis-target-scoped
    compilation database, and convert library
    target source directories and library target public
    include directories to PCLP options (target_libraries.lnt).;
end group
stop
```

!!! warning
    Although most typical use cases should be covered, support for generator expressions remains limited due to their complex nature. Some special-case generator expressions require more manual evaluation than others (via custom parsing).  Current implementation does not support nested generator expressions that contain any of these special-case generator expressions.  If this condition is detected a CMake error is generated.  See [PLXSEP-1172](https://eng.plexus.com/jira/browse/PLXSEP-1172) for more details.

## Debugging

Error findings (versus warning or informational findings) generated during PCLP analyses are typically the result of incorrect or incomplete configuration.  Several pieces of information are available to review when debugging a suspected configuration problem.

* the output of automated CMake configuration during PCLP configuration invoked automatically from the `tools/pclp/scripts/analyze.sh` script. To make analysis output more user-friendly, this CMake configuration output is typically suppressed, however this suppression can be removed when debugging.
* the PCLP configuration inputs generated during automated CMake configuration as part of the `tools/pclp/scripts/analyze.sh` script which can be found in `<build>/pclp/<target>`
* PCLP output (see the PCLP manual for more details how to make this output more verbose)
