import Counterexample

open SchemesAudit

namespace SheafExamples

-- ANCHOR: sheafCounterexample
theorem largeRing_not_isSheaf_commRing :
    ¬ (boundedRing (discreteSpace (ℝ → ℤ)) (ℝ → ℤ)).IsSheaf
-- ANCHOR_END: sheafCounterexample
    := SchemesAudit.largeRing_not_isSheaf_commRing

end SheafExamples
