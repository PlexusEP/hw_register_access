# Uncrustify as a Potential Alternative to Clang-Tidy

Uncrustify used to be the standard code styling solution.  However, we moved away from it for two reasons.  First, there was a defect where contents of entire files would be inadvertantly replaced.  Second, multiple teams expressed that they were unable to configure it the way they wanted, and that they'd prefer Clang-Format.  
  
For more details on the defect, see [this Jira story](https://eng.plexus.com/jira/browse/ALMSCAD-1865).  
  
Defect aside, for more details on how Uncrustify might be included as the automated code styling solution, see the changes that were undone as part of [this Git pull request](https://eng.plexus.com/git/projects/EP/repos/cpp-project-template/pull-requests/30/overview).