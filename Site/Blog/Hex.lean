import VersoBlog
import Site.Categories
open Verso Genre Blog
open Verso.Code.External

set_option linter.verso.markup.emph false

-- Default module for the linear-algebra sections. Later sections select their
-- own module (with its own imports) via `(module := ...)` on the anchor block.
set_option verso.exampleProject "examples/hex"
set_option verso.exampleModule "HexExamples.Core"

#doc (Post) "Lattice basis reduction using the Hex Lean library" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 7, day := 7}
categories := [Site.algebra, Site.lean]
%%%

We're starting work on a computational algebra library for Lean, called [`Hex`](https://github.com/leanprover/hex).
We've just released the first collection of packages, providing dense matrices, row reduction, Gram-Schmidt, and lattice basis reduction.

These packages have a primarily computational focus (i.e. calculations on concrete inputs, rather than symbolic algebra),
and are optimized first for runtime performance, and secondarily for performance during kernel reduction.

The whole library is developed using "spec driven development". This means we write specifications ahead of time,
then use AIs to implement (both the executable components and the formal verifications of these).
Contributions to the library are welcome, but new features should come with a specification first!

There's a [manual](https://kim-em.github.io/hex-dev/), [online reference documentation](https://leanprover.github.io/hex/), and a [discussion thread](https://leanprover.zulipchat.com/#narrow/channel/482893-Computer-algebra/topic/Discussion.3A.20Hex) on the leanprover Zulip instance.

In the rest of this blog post, I'll give you a very quick walkthrough of the basic functionality,
then show how we can put it together to execute the Coppersmith attack on RSA.

Everything here is written in [Verso](https://verso.lean-lang.org), the Lean-native document preparation system.
This means all the code samples are compile time checked,
then rendered into a webpage with type information in hovers
and intermediate goal states available in proofs.

Getting started: `Hex` provides a {anchorName glossary}`Matrix` type for representing dense matrices over an arbitary type
(Right now, {anchorTerm glossary}`Matrix R n m` := {anchorTerm glossary}`Vector (Vector R m) n`, but we've encapsulated the definition so, for example,
we could swap it out later as {anchorTerm glossary}`Vector R (n * m)` for the sake of performance, without affecting downstream users.)

We provide basic tools for constructing matrices, extracting rows, columns, and entries, and basic matrix arithmetic:
```anchor arithmetic
-- A 3×3 integer matrix.
def A : Matrix Int 3 3 :=
  #m[2, 0, 1;
     1, 3, 2;
     0, 1, 1]

#guard A.getRow 1 = #v[1, 3, 2]
#guard A.mulVec #v[1, 1, 1] = #v[3, 6, 2]
#guard (A + 2 • Matrix.identity 3)[(1, 1)] = 5
```

The {anchorName glossary}`Matrix.det` function is just the usual Leibniz formula for the determinant;
it's not efficient, but we provide some alternatives later. It's defined over any ring.
```anchor determinant
-- A matrix of rationals.
def B : Matrix Rat 3 3 :=
  #m[2, 0,   1;
     1, 3/7, 2;
     0, 1,   1]

#guard det B = -15/7
#guard det (transpose B) = -15/7
#guard det (rowSwap B 0 1) = 15/7

-- A matrix with linearly dependent rows is singular.
def S : Matrix Int 2 2 :=
  #m[1, 2;
     2, 4]
#guard det S = 0
```

We can row reduce a matrix over a field,
compute the rank, a basis for the nullspace, and determine if a vector is in the span of the rows.
The function {anchorName glossary}`Matrix.rowReduce` returns a {anchorName glossary}`RowEchelonData`, from which we can compute the rest efficiently.
```anchor rowreduce
def M : Matrix Rat 2 3 :=
  #m[1, 2, 3;
     2, 4, 6]

#guard (rowReduce M).rank = 1

#guard (nullspace M).toList = [#v[-2, 1, 0], #v[-3, 0, 1]]

#guard spanContains M #v[3, 6, 9] = true
#guard spanContains M #v[1, 0, 0] = false
```

We can do Gram-Schmidt orthogonalization
(and under the hood there are efficient algorithms that avoid division when we work over the integers).

```anchor gramschmidt
-- A 3×3 rational matrix, orthogonalized row by row (left to right).
def m : Hex.Matrix Rat 3 3 := #m[1, 1, 0; 1, 0, 1; 0, 1, 1]

-- Each row has its projection onto the earlier rows subtracted off.
#guard basisMatrix m = #m[  1,    1,   0;
                          1/2, -1/2,   1;
                         -2/3,  2/3, 2/3]

-- The resulting rows are pairwise orthogonal.
#guard ((basisMatrix m).row 0).dotProduct ((basisMatrix m).row 1) = 0
#guard ((basisMatrix m).row 0).dotProduct ((basisMatrix m).row 2) = 0
#guard ((basisMatrix m).row 1).dotProduct ((basisMatrix m).row 2) = 0
```

Over the integers, the leading Gram determinants are computed exactly, without any division:
```anchor gramdet
-- Over the integers, the leading Gram determinants d₀..d₃ (the squared volumes
-- of the prefix sublattices) are computed exactly, without any division.
def m : Hex.Matrix Int 3 3 := #m[1, 1, 0; 1, 0, 1; 0, 1, 1]

#guard gramDet m 0 = 1
#guard gramDet m 1 = 2
#guard gramDet m 2 = 3
#guard gramDet m 3 = 4
```

Lattice basic reduction is available via a verified implementation of the LLL algorithm.
With this, we can efficiently find a short vector in a lattice,
and prove that this vector is only a constant (depending on the dimension)
times the length of the optimal shortest vector.

```anchor lll
-- A skewed rank-2 basis: the first row is far from orthogonal.
def B : Hex.Matrix Int 2 2 := #m[1, 12; 0, 1]

-- Reduction returns the two unit vectors: same lattice, as short as possible.
#guard lll B (3 / 4) = #m[0, 1; 1, 0]

-- The verified integer checker rejects the input (not size-reduced) and
-- accepts the output.
#guard lllReduced B (3 / 4) (11 / 20) = false
#guard lllReduced (#m[0, 1; 1, 0] : Hex.Matrix Int 2 2) (3 / 4) (11 / 20) = true
```

This verified implementation is even pretty fast, e.g. faster than the existing
formally verified implementation in Isabelle.

![LLL reducers on NTRU-style lattices: Lean and Isabelle native, and the certified paths, against raw fpLLL](/figures/hex-lll-comparator-ntru.svg)

Moreover we also have a version
that delegates the heavy computation to the optimized C library fplll, but still
formally verifies a certificate proving the length bound. Again, it's quite fast!

![LLL reducers on harsh-cubic bases, where the entry bit-length grows with the dimension](/figures/hex-lll-comparator-harsh-cubic.svg)

We can perform the standard parlour trick with lattice basis reduction:
discover the minimal polynomial from a decimal approximation of an algebraic number.
```anchor minpoly
-- We recover the minimal polynomial of α = 1.220744…, knowing only
-- that α is a root of some integer polynomial of degree ≤ 4.
-- We form one lattice row for each power of α:
-- eᵢ in the first five columns, and ⌊10⁶·αⁱ⌋ in the last.
def L : Hex.Matrix Int 5 6 :=
  #m[1, 0, 0, 0, 0, 1000000;
     0, 1, 0, 0, 0, 1220744;
     0, 0, 1, 0, 0, 1490216;
     0, 0, 0, 1, 0, 1819173;
     0, 0, 0, 0, 1, 2220744]

-- The shortest reduced row reads off (a₀,a₁,a₂,a₃,a₄) = (−1,−1,0,0,1) with a
-- zero last coordinate: the relation −1 − α + α⁴ = 0.
#guard (lll L (3 / 4)).row 0 = #v[-1, -1, 0, 0, 1, 0]
```

And for a final trick, we can run the Coppersmith attack on RSA.
Here we assume that we're trying to decrypt a templated message,
where we already know most of the plain text, there's just a short unknown field.
We also assume we're using a small public exponent, in this case `e := 3`.

As a quick reminder of how RSA works, `N` is a product of two large primes
(but the factorization is known only to the intended receiver), for a message `m`,
the ciphertext is `c = m³ mod N`.

The intended receiver knows the factorization `N = p·q`, so they can compute
`φ(N) = (p−1)(q−1)` and a private exponent `d` with `3·d ≡ 1 (mod φ(N))`.
Then `cᵈ ≡ m^{3d} ≡ m (mod N)` recovers the message.
An attacker who knows only `N` cannot compute `φ(N)` (or `d`) without factoring
`N`, which is believed to be hard, so this is where RSA's security usually lives.
The attack below sidesteps factoring entirely, exploiting the small exponent
`e = 3` and the fact that we already know most of the message.

For the Coppersmith attack, we assume the message is of the form
`m = a + x₀`, where `0 ≤ x₀ < X` for some relatively small `X`,
and `a` and `X` are both known to the attacker.

Since `c = m³ mod N` and `m = a + x₀`, the unknown `x₀` is a root *modulo `N`* of
`f(x) = (a + x)³ − c`,
that is, `f(x₀) ≡ 0 (mod N)`. This is much weaker than an honest integer root:
we can't just factor `f` over `ℤ` to read `x₀` off.

Howgrave-Graham's idea is to trade `f` for a *different* polynomial `g` sharing
the same small root `x₀`, but with coefficients small enough that a congruence
mod `N` becomes an equation over `ℤ`. Suppose `g(x) = Σⱼ gⱼ xʲ` also satisfies
`g(x₀) ≡ 0 (mod N)`. Since `0 ≤ x₀ < X`,
`|g(x₀)| ≤ Σⱼ |gⱼ| Xʲ`.
If that bound is below `N`, then `g(x₀)` is an integer divisible by `N` yet
smaller than `N` in absolute value, so it is exactly `0`. Now `x₀` is a genuine
integer root of `g`, recoverable by a short scan (or, at scale, by factoring `g`).

So we want a `g` with `g(x₀) ≡ 0 (mod N)` and small `Σⱼ |gⱼ| Xʲ`. Both are linear
conditions, which is exactly what a lattice captures. Take integer combinations of
the four polynomials `N`, `N·x`, `N·x²`, and `f(x)`: each vanishes at `x₀` modulo
`N` (the first three because they are multiples of `N`, and `f` by construction),
so every integer combination does too. We record a combination by its coefficient
vector, with column `j` scaled by `Xʲ` — that is the matrix `B` below. The
Euclidean length of a lattice vector is then `√(Σⱼ gⱼ² X^{2j})`, which controls
`Σⱼ |gⱼ| Xʲ`. A *short* vector is therefore precisely a `g` with the
small-coefficient property we need: LLL produces one, Howgrave-Graham's bound
upgrades `≡ 0 (mod N)` to `= 0`, and the root drops out.

This single-shift lattice reaches roots up to about `N^{1/6}` (its determinant is
`N³·X⁶`, and LLL's shortest vector is around `(N³X⁶)^{1/4}`, which stays below `N`
exactly when `X < N^{1/6}`).
In the next example in this blog post we'll also consider shift polynomials
`xⁱ·f(x)ʲ` which enlarge the lattice and push the reachable bound toward `N^{1/3}`.

```anchor coppersmithToy (module := HexExamples.Coppersmith)
-- A courier RSA-encrypts a templated message m = a + x₀ with exponent 3 and no
-- padding; a is the known template, x₀ a two-digit code with 0 ≤ x₀ < X. The
-- ciphertext is c = m³ mod N. Only N, a, c, X are public; recover x₀.

-- Public data the attacker starts from.
def N : Nat := 10_000_004_400_000_259
def X : Nat := 100
def a : Int := 55_555_500
def c : Int := 6_804_005_608_230_644

-- Coefficients of f(x) = (a + x)³ − c, reduced mod N.
def a0 := (a ^ 3 - c).bmod N
def a1 := (3 * a ^ 2).bmod N
def a2 := (3 * a).bmod N

-- The Coppersmith lattice: one polynomial per row, degree-j column scaled by
-- Xʲ, so "small coefficients" becomes "short vector". Rows N, N·x, N·x², f.
def B : Matrix Int 4 4 :=
  #m[(N : Int), 0,      0,          0;
     0,         N * X,  0,          0;
     0,         0,      N * X * X,  0;
     a0,        a1 * X, a2 * X * X, X * X * X]

-- LLL-reduce with the default δ = 3/4.
def reduced : Matrix Int 4 4 := lll B

-- De-scale a reduced row back to integer polynomial coefficients.
def descale (r : Vector Int 4) : Option (Vector Int 4) :=
  if r[1] % X == 0 && r[2] % (X * X) == 0 && r[3] % (X * X * X) == 0 then
    some #v[r[0], r[1] / X, r[2] / (X * X), r[3] / (X * X * X)]
  else
    none

-- Horner evaluation of a degree-3 integer polynomial.
def evalPoly (g : Vector Int 4) (x : Int) : Int :=
  ((g[3] * x + g[2]) * x + g[1]) * x + g[0]

-- Scan the reduced rows for an integer root that reproduces the ciphertext.
def recover : Option Int := Id.run do
  for row in reduced.rows do
    match descale row with
    | none => pure ()
    | some g =>
      for x in [0:100] do
        if evalPoly g x == 0 && (a + x) ^ 3 % N == c then
          return some x
  return none

-- LLL genuinely reduced the basis, and the recovered code is 37,
-- perhaps no surprise given we're working in Lean!
#guard lllReduced reduced == true
#guard recover == some 37
```

We can scale this up if we like! The next example takes advantage of a
complete-but-unreleased part of the Hex library, namely fast integer polynomial factorization,
using Berkelekamp-Zassenhaus and van Hoeij reconstruction (in fact, this uses LLL internally again).
To access these, we have to import that `hex-dev` development monorepo.

This time we use a realistic 2048-bit RSA modulus, and a 400-bit secret.
We use a larger lattice, which gives us a better chance of finding a short vector with the desired property.
Because the unknown field in the message is now 400 bits long,
it is not feasible to search for a linear root of the polynomial `g` once we have it;
instead we directly factor `g` over the integers, and search its linear factors.

```anchor coppersmithFull (module := HexExamples.Coppersmith)
-- A 2048-bit RSA modulus N = p * q, with p and q the primes
-- just below 2^1024. Exponent e = 3, no padding.
def p : Nat := 2 ^ 1024 - 105
def q : Nat := 2 ^ 1024 - 179
def N : Nat := p * q

-- The known 1202-bit template a and unknown 400-bit secret
-- x0 give c = (a + x0)^3 mod N. The attacker sees only the
-- public data N, a, c, and the bound X.
def a  : Int := 3 ^ 758
def x0 : Int := 2 ^ 399 + 271828182
def X  : Nat := 2 ^ 400
def c  : Int := (a + x0) ^ 3 % N

-- f(x) = (a + x)^3 - c, reduced mod N to small coeffs, as a Hex polynomial.
def f : ZPoly :=
  DensePoly.ofCoeffs #[(a ^ 3 - c).bmod N, (3 * a ^ 2).bmod N, (3 * a).bmod N, 1]

-- Nine polynomials N^(2-j) · xⁱ · f(x)ʲ (j, i in 0,1,2). Each vanishes at x0
-- mod N²; the added shift polynomials push the recoverable bound from ~N^(1/6)
-- toward N^(1/3), covering a 400-bit root.
def rows : Array ZPoly := Id.run do
  let mut rs : Array ZPoly := #[]
  let mut fj : ZPoly := 1
  for j in [0:3] do
    for i in [0:3] do
      rs := rs.push (DensePoly.monomial i ((N : Int) ^ (2 - j)) * fj)
    fj := fj * f
  return rs

-- The lattice basis: row i, column k is the degree-k coefficient scaled by X^k.
def B : Matrix Int 9 9 :=
  Matrix.ofFn fun i k => (rows.getD i.val 0).coeff k.val * X ^ k.val

def reduced : Matrix Int 9 9 := lll B

-- De-scale a reduced row into a Hex polynomial: coefficient k divides by X^k.
def descale (r : Vector Int 9) : ZPoly :=
  DensePoly.ofCoeffs (Array.ofFn fun k : Fin 9 => r[k] / X ^ k.val)

-- LLL sorts the shortest vector into the first row; de-scale it to `g`.
def g : ZPoly := descale (reduced.row 0)

-- Factor g over Z with Berlekamp-Zassenhaus. The secret is
-- the root of its linear factor x - x0. Scanning x below
-- X ~ 2^400 is hopeless; factoring degree-8 g is instant.
def recovered : Option Int := Id.run do
  for (fac, _) in g.factors do
    match fac.toArray with
    | #[q, p] => -- a linear factor `p * X + q`
      if q % p == 0 then
        let r := -q / p
        if 0 ≤ r && r < X && (a + r) ^ 3 % N == c then
          return some r
    | _ => continue
  return none

-- The modulus is 2048 bits; the secret is about 400 bits.
#guard N > 2 ^ 2047 && N < 2 ^ 2048
#guard x0 > 2 ^ 399

-- LLL reduces the basis; factoring g gives back x0.
#guard lllReduced reduced == true
#guard recovered == some x0
```

The computational libraries described above are independent of Mathlib
(indeed they have no dependencies except amongst themselves),
so can be used in any Lean project.

For each library in `Hex`, there is a companion library that additionally depends on Mathlib,
which identifies relevant structures, and sometimes proves additional theorems
about the computations in Hex whose proofs require more algebraic machinery.
(For the lattice basis reduction algorithm above,
we can in fact prove the short vector bound without needing anything in Mathlib.
In future sublibraries, e.g. the fact that the "fast path" for integer polynomial factorization
always completes successfully, and we never need to fall back to the "slow path",
requires some number theory from Mathlib.)

Here, with the additional `import HexRowReduceMathlib`, we demonstrate
how to compute the rank of a Mathlib matrix, via transfer to Hex's machinery.
Once the statement has been transferred, we resolve it with `decide +kernel`.

```anchor mathlibRank (module := HexExamples.Mathlib)
-- `A` is an ordinary Mathlib matrix; `A.rank` is Mathlib's noncomputable rank.
def A : _root_.Matrix (Fin 2) (Fin 3) Rat := !![1, 2, 3; 2, 4, 6]

theorem rank_eq_one : A.rank = 1 := by
  -- Rewrite the noncomputable rank into the executable one, then decide it in
  -- the kernel. No `native_decide`: the compiler is not in the trusted base.
  rw [← matrixEquiv.apply_symm_apply A,
      ← rank_eq (rowReduce_isRowReduced _)]
  decide +kernel
```

Some final notes.

For now Hex is mostly optimized for runtime performance,
and you may find some places where kernel reduction is slow or impossible:
please report these!

We've only thought about efficiently calculating determinants over `Int`,
because we need this for lattice basis reduction, but the Bareiss algorithm
could be generalized, or we could use preliminary row reduction when working over a field.

Hex is a spec driven development library, and so little attempt has been made
to "golf" proofs or even to make them particularly readable.
Contributions cleaning up proofs are welcome.

You can get the entire released Hex package by adding
```
[[require]]
name = "hex"
git = "https://github.com/leanprover/hex"
rev = "main"
```
in your `lakefile.toml`, and then `import Hex`.
(If you want individual sublibraries, instead require just the one you need, e.g.
`name = "hex-lll"`, `git = "https://github.com/leanprover/hex-lll"`, and `import HexLLL`.)

Unreleased libraries, and all future development, live at [github.com/kim-em/hex-dev](https://github.com/kim-em/hex-dev).
Contributions and pull requests are welcome, but specs must be updated *before* any new features or substantial changes,
as separately reviewed PRs.
