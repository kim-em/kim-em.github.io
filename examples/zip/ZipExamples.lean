import Zip.Spec.DeflateRoundtripProduction

/-!
Each `ANCHOR` region is pulled into the blog post by Verso.

The post quotes one theorem, the DEFLATE roundtrip capstone. Rather than
retyping it, the anchor below restates it and discharges it with the real
theorem from `lean-zip`: if the library's statement ever drifts from the one on
the page, this file stops compiling and the site build fails.
-/

namespace ZipExamples

open Zip.Native.Deflate (deflateRaw)
open Zip.Native.Inflate (inflate)

-- ANCHOR: roundtrip
/-- Unified DEFLATE roundtrip: inflating what we deflate returns the input exactly. -/
theorem inflate_deflateRaw (data : ByteArray) (level : UInt8)
    (maxOutputSize : Nat) (hsize : data.size ≤ maxOutputSize) :
    inflate (deflateRaw data level) maxOutputSize = .ok data :=
  Zip.Native.Deflate.inflate_deflateRaw data level maxOutputSize hsize
-- ANCHOR_END: roundtrip

end ZipExamples
