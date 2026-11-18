import VersoBlog
import Site.Examples
open Verso Genre Blog
open Verso.Code.External

set_option verso.exampleProject "examples/sheaves"
set_option verso.exampleModule "SheafExamples"

load_examples "examples/sheaves"

#doc (Post) "Mathlib statement" =>

```anchor sheafCounterexample
theorem largeRing_not_isSheaf_commRing :
    ¬ (boundedRing (discreteSpace (ℝ → ℤ)) (ℝ → ℤ)).IsSheaf
```
