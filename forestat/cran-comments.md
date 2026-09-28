## R CMD check results

0 errors | 0 warnings | 2 notes

* The DOI `10.3390/f8040119`, which is unchanged from forestat 1.1.0,
  returned HTTP status 403 during the automated URL check. The DOI is valid.
* The GitHub project and issue URLs timed out in the local check environment;
  both URLs are valid and publicly accessible.
* The local Windows check environment was unable to verify the current time.

## Changes

* Exported `FittingEvaluationIndex()` for calculating model fitting evaluation
  indices.
* Added and documented the `birch`, `larch`, and `picea` datasets.
* Updated the package vignette with examples for the new datasets and exported
  function.
* Existing datasets and previously exported functions remain unchanged.
