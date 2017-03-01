import data.set
open set

---------------------------------------------------------------------------------
--  Chapter 3 - Set theory
--  Analysis 1, Third Edition, Tao                                             
---------------------------------------------------------------------------------

section

universe u
variables {α : Type u} {A B C : set α}

-- As of Lean 3.0, certain set operations aren't defined. They are below.

-- Definition 3.1.4
lemma ext_eq {a b : set α} (h : ∀ x, x ∈ a ↔ x ∈ b) : a = b :=
funext (take x, propext (h x))

lemma exti {a b : set α} (h : a = b) : ∀ x, x ∈ a ↔ x ∈ b :=
take x, iff.intro (assume h2, h ▸ h2) (assume h2, h^.symm ▸ h2)

definition diff {α} (s t : set α) : set α := {x ∈ s | x ∉ t}
infix ` ∖ `:70 := diff

definition strict_subset {α} (s t : set α) := s ⊆ t ∧ s ≠ t
infix ` ⊊ `:50 := strict_subset

-- Exercise 3.1.1. Show that the definition of equality in (3.1.4) is reflexive,
-- symmetric, and transitive.

example : A = A := 
ext (take x, show x ∈ A ↔ x ∈ A, from iff.intro id id)

example : A = B → B = A := 
assume h1, have h2 : _, from exti h1, ext (take x, iff.symm (h2 _))

example : A = B → B = C → A = C :=
assume h1 h2, 
  have h3 : _, from exti h1,
  have h4 : _, from exti h2,
  ext (take x,
    have h5 : _, from h3 x,
    have h6 : _, from h4 x,
    iff.trans h5 h6)

-- Exercise 3.1.2. Using only definition 3.1.4, axiom 3.2, and axiom 3.3, prove
-- that the sets ∅, {∅}, and {{∅}}, and {∅,{∅}} are all distinct
lemma mem_singleton {α} (a : α) : a ∈ ({a} : set α) := or.inl rfl

lemma empty_ne {α} : (∅ : set (set α)) ≠ {∅} :=
assume h : ∅ = {∅},
have ∅ ∈ ({∅} : set (set α)), from mem_singleton _,
have ∅ ∈ (∅ : set (set α)), from eq.rec_on h^.symm this,
absurd this (not_mem_empty _).

-- The other pairwise inequalities can be shown using the method above.

-- Exercise 3.1.3. Prove the remaining claims in Lemma 3.1.12.

example : A ∪ B = B ∪ A := ext (take x, or.comm).
example : A ∪ A = A := ext (take x, or_self _).
example : A ∪ ∅ = A := ext (take x, or_false _).
example : ∅ ∪ A = A := ext (take x, false_or _).

-- Exercise 3.1.4. Prove the remaining claims in Proposition 3.1.17. 

example (h1 : A ⊆ B) (h2 : B ⊆ A) : A = B := 
ext (take x, iff.intro (assume h3, h1 h3) (assume h3, h2 h3))

example (h1 : A ⊆ B) (h2 : A ≠ B) (h3 : B ⊆ C) (h4 : B ≠ C) : A ⊆ C ∧ A ≠ C := 
and.intro 
  (take x, assume h5 : x ∈ A, 
    have h6 : ∀ x, x ∈ B → x ∈ C, from h3, 
    have h7 : ∀ x, x ∈ A → x ∈ B, from h1, 
    h6 x (h7 x h5))
  (assume h5,
    have h6 : _, from exti h5,
    have h7 : ∀ x, x ∈ A → x ∈ B, from h1,
    have h8 : ∀ x, x ∈ B → x ∈ C, from h3,
    have h9 : ∀ x, x ∈ C → x ∈ A, from 
      take x, 
      have x ∈ A ↔ x ∈ C, from h6 x, 
      iff.mpr this,
    have h10: ∀ x, x ∈ C → x ∈ B, from take x, assume h10, h7 x (h9 x h10), 
    h4 (ext (take x, iff.intro (h8 x) (h10 x)))).

-- Exercise 3.1.5. Let A, B be sets. Show that the three statements 
-- A ⊆ B, A ∪ B = B, and A ∩ B = A are logically equivalent. 

example : A ⊆ B → A ∪ B = B :=
assume h1 : ∀ x, x ∈ A → x ∈ B,
ext (take x, iff.intro 
  (assume  h2 : x ∈ A ∨ x ∈ B, 
    or.elim h2 
      (h1 x)  
      (id)) 
  (assume h2 : x ∈ B, or.inr h2))

example : A ⊆ B → A ∩ B = A :=
assume h1 : ∀ x, x ∈ A → x ∈ B,
suffices ∀ (x : α), x ∈ A ∩ B ↔ x ∈ A, from ext this, 
take x, iff.intro
  (assume h2 : x ∈ A ∧ x ∈ B, h2^.left)
  (assume h2 : x ∈ A, 
    and.intro (h2) (h1 x h2))

example : A ∪ B = B → A ⊆ B :=
assume h1 :  A ∪ B = B,
have h2 : ∀ x, x ∈ A ∨ x ∈ B ↔ x ∈ B, from exti h1, 
take x, assume h3 : x ∈ A,
iff.mp (h2 x) (or.inl h3)

example : A ∪ B = B → A ∩ B = A :=
assume h1, ext (take x,
  (iff.intro 
    (assume h2, h2^.left) 
    (have h2 : x ∈ A ∨ x ∈ B ↔ x ∈ B, from exti h1 x, 
      assume h3 : x ∈ A, and.intro (h3) (iff.mp h2 (or.inl h3)))))

example : A ∩ B = A → A ⊆ B :=
assume h1,
take x, 
have h2 : x ∈ A ∧ x ∈ B ↔ x ∈ A, from exti h1 x,
have h3 : x ∈ A → x ∈ A ∧ x ∈ B, from iff.mpr h2,
assume h4, have h5 : x ∈ A ∧ x ∈ B, from h3 h4, h5^.right

example : A ∩ B = A → A ⊆ B :=
assume h1, take x, assume h2,
have h3 : x ∈ A ∧ x ∈ B ↔ x ∈ A, from exti h1 x, 
have x ∈ A → x ∈ A ∧ x ∈ B, from iff.mpr h3,
have x ∈ A ∧ x ∈ B, from this h2, this^.right

-- Exercise 3.1.6. Prove the remaining claims in Proposition 3.1.27.
section balg

-- a lot of these are trivially provable in Lean because of how sets are defined
variable X : set α
premises (h1 : A ⊆ X) (h2 : B ⊆ X) (h3 : C ⊆ X)

-- minimal element
example : A ∪ ∅ = A := ext (take x, or_false (x ∈ A))
example : A ∩ ∅ = ∅ := ext (take x, and_false (x ∈ A))

-- maximal element
example : A ∪ X = X := ext (take x, iff.intro 
  (assume h4 : x ∈ A ∨ x ∈ X, or.elim h4 (assume h5, h1 h5) (id)) 
  (assume h4, or.inr h4))

example : A ∩ X = A := ext (take x, iff.intro
  (assume h4 : x ∈ A ∧ x ∈ X, h4^.left)
  (assume h4 : x ∈ A, and.intro (h4) (h1 h4)))

-- identity
example : A ∩ A = A := ext (take x, and_self _)
example : A ∪ A = A := ext (take x, or_self _)

-- commutativity
example : A ∪ B = B ∪ A := ext (take x, or.comm)
example : A ∩ B = B ∩ A := ext (take x, and.comm)

-- associativity
example : A ∪ B ∪ C = A ∪ (B ∪ C) := ext (take x, or.assoc)
example : A ∩ B ∩ C = A ∩ (B ∩ C) := ext (take x, and.assoc)

-- distributivity 
example : A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) := ext (take x, iff.intro
  (assume ⟨(h4 : x ∈ A), (h5 : x ∈ B ∨ x ∈ C)⟩, 
    or.elim h5 
      (assume h6 : x ∈ B, or.inl (and.intro h4 h6))
      (assume h6 : x ∈ C, or.inr (and.intro h4 h6)))
  (assume h4 : x ∈ A ∧ x ∈ B ∨ x ∈ A ∧ x ∈ C, 
    or.elim h4 
      (assume h5, and.intro (h5^.left) (or.inl h5^.right)) 
      (assume h5, and.intro (h5^.left) (or.inr h5^.right))))

example : A ∪ (B ∩ C) = (A ∪ B) ∩ (A ∪ C) := ext (take x, iff.intro
  (assume h4, and.intro 
    (or.elim h4 
      (assume h5, or.inl h5) 
      (assume h5, or.inr h5^.left)) 
    (or.elim h4 
      (assume h5, or.inl h5) 
      (assume h5, or.inr h5^.right))) 
  (assume ⟨(h4 : x ∈ A ∨ x ∈ B), (h5 : x ∈ A ∨ x ∈ C)⟩, 
    or.elim h4 
      (assume h6, or.inl h6) 
      (assume h6, or.elim h4 
        (or.elim h5 
          (assume h7 h8, or.inl h7) 
          (assume h7 h8, or.inl h8)) 
        (or.elim h5 
          (assume h7 h8, or.inl h7) 
          (assume h7 h8, or.inr (and.intro h8 h7))))))

-- partition
example : A ∪ (X ∖ A) = X := ext (take x, iff.intro
  (assume h4, or.elim h4 
    (assume h5, h1 h5) 
    (assume h5 : x ∈ X ∧ x ∉ A, h5^.left))
  (assume h4, or.elim (classical.em (x ∈ A)) 
    (λ h5 : x ∈ A, or.inl h5) 
    (λ h5, or.inr (and.intro h4 h5))))

example : A ∩ (X ∖ A) = ∅ := ext (take x, iff.intro
  (assume ⟨h4, h5, h6⟩, absurd h4 h6)
  (assume h4, have h5 : _, from not_mem_empty x, absurd h4 h5))

-- De Morgan laws
example : X ∖ (A ∪ B) = (X ∖ A) ∩ (X ∖ B) := ext (take x, iff.intro 
  (assume ⟨(h4 : x ∈ X), (h5 : ¬(x ∈ A ∨ x ∈ B))⟩, 
    and.intro 
      (and.intro (h4) (assume h6, h5 (or.inl h6))) 
      (and.intro (h4) (assume h6, h5 (or.inr h6))))
  (assume ⟨⟨h4, h5⟩, h6, h7⟩, 
    and.intro (h6) (assume h8 : x ∈ A ∨ x ∈ B, or.elim h8 
      (assume h9, absurd h9 h5) 
      (assume h9, absurd h9 h7))))

example : X ∖ (A ∩ B) = (X ∖ A) ∪ (X ∖ B) := ext (take x, iff.intro
  (assume ⟨h4, (h5 : ¬(x ∈ A ∧ x ∈ B))⟩, 
    (or.elim (classical.em (x ∈ A)) 
      (or.elim (classical.em (x ∈ B)) 
        (assume h6 h7, or.inl (and.intro h4 (assume h8, h5 ⟨h7, h6⟩))) 
        (assume h6 h7, or.inr (and.intro h4 h6))) 
      (assume h6, or.inl (and.intro h4 h6)))) 
  (assume h4, or.elim h4 
    (assume ⟨h5, h6⟩, and.intro h5 
      (assume ⟨h7, h8⟩, absurd h7 h6)) 
    (assume ⟨h5, h6⟩, and.intro h5 
      (assume ⟨h7, h8⟩, absurd h8 h6)))) 

end balg

-- Exercise 3.1.7. Let A, B, and C be sets. Show that A ∩ B ⊆ A and A ∩ B ⊆ B. 
-- Furthermore, show that C ⊆ A and C ⊆ B if and only if C ⊆ A ∩ B. In a similar
-- spirit, show that A ⊆ A ∪ B and B ⊆ A ∪ B, and furthermore that A ⊆ C and 
-- B ⊆ C if and only if A ∪ B ⊆ C.

example : A ∩ B ⊆ A := take x, assume h1 : x ∈ A ∧ x ∈ B, h1^.left
example : A ∩ B ⊆ B := take x, assume h1 : x ∈ A ∧ x ∈ B, h1^.right

example : C ⊆ A ∧ C ⊆ B ↔ C ⊆ (A ∩ B) := 
iff.intro 
  (assume ⟨h1, h2⟩, take x, assume h3, and.intro (h1 h3) (h2 h3)) 
  (assume h1 : ∀ {x}, x ∈ C → x ∈ (A ∩ B), and.intro 
    (take x, assume h2, have h3 : x ∈ A ∧ x ∈ B, from h1 h2, h3^.left) 
    (take x, assume h2, have h3 : x ∈ A ∧ x ∈ B, from h1 h2, h3^.right))

example : A ⊆ A ∪ B := λ x h, or.inl h
example : B ⊆ A ∪ B := λ x h, or.inr h

example : A ⊆ C ∧ B ⊆ C ↔ A ∪ B ⊆ C :=
iff.intro
  (assume ⟨h1, h2⟩, λ x h3, or.elim h3 (λ h4, h1 h4) (λ h4, h2 h4))
  (assume h1 : ∀ {x}, x ∈ (A ∪ B) → x ∈ C, and.intro 
    (λ x h2, h1 (or.inl h2)) 
    (λ x h2, h1 (or.inr h2)))

-- Exercise 3.1.8. Let A and B bet sets. Prove the absorption laws
--  A ∩ (A ∪ B) = A and A ∪ (A ∩ B) = A.

example : A ∩ (A ∪ B) = A := ext (take x, 
iff.intro 
  (λ ⟨h1, h2⟩, h1) 
  (λ h1, and.intro h1 (or.inl h1)))

example : A ∪ (A ∩ B) = A := ext (take x,
iff.intro
  (λ h1, or.elim h1 id (λ ⟨h2, h3⟩, h2))
  (λ h1, or.inl h1))

-- Exercise 3.1.9. Let A, B, and X be sets such that A ∪ B = X and A ∩ B = ∅. 
-- Show that A = X ∖ B and B = X ∖ A.

example (X : set α) (h1 : A ∪ B = X) (h2 : A ∩ B = ∅) : A = X ∖ B ∧ B = X ∖ A :=
and.intro 
  (ext (take x, iff.intro 
    (assume h3 : x ∈ A, and.intro 
      (have h4 : _, from exti h1 x, 
        have h5 : x ∈ A ∨ x ∈ B, from or.inl h3, iff.mp h4 h5) 
      (assume h4, 
        have h5 : _, from exti h2 x, 
        have h6 : x ∈ ∅, from iff.mp h5 ⟨h3, h4⟩, 
        absurd h6 (not_mem_empty _))) 
    (assume ⟨h3, h4⟩, 
      have h5 : _, from iff.mpr (exti h1 x) h3, or.elim h5 (id) 
        (assume h6, absurd h6 h4))))
  (ext (take x, iff.intro 
    (assume h3, and.intro 
      (have h4 : _, from iff.mp (exti h1 x), h4 (or.inr h3)) 
      (assume h4, have h5 : _, from iff.mp (exti h2 x), h5 ⟨h4, h3⟩))
    (assume ⟨h3, h4⟩, have h5 : _, from iff.mpr (exti h1 x) h3, 
      or.elim h5 (assume h6, absurd h6 h4) (id))))

-- Exercise 3.1.10. Let A and B be sets. Show that the three sets A ∖ B, A ∩ B 
-- and B ∖ A are disjoint, and that their union is A ∪ B.

example : (A ∖ B) ∩ (A ∩ B) = ∅ := ext (take x, 
iff.intro 
  (assume ⟨⟨h1, h2⟩, h3, h4⟩, absurd h4 h2) 
  (assume h1, have h2 : _, from not_mem_empty x, absurd h1 h2)) 

example : (A ∩ B) ∩ (B ∖ A) = ∅ := ext (take x, iff.intro
  (assume ⟨⟨h1, h2⟩, _, h3⟩, absurd h1 h3)
  (assume h1, absurd h1 (not_mem_empty x)))

example : (A ∖ B) ∩ (B ∖ A) = ∅ := ext (take x, iff.intro 
  (assume ⟨⟨h1, h2⟩, h3, h4⟩, absurd h1 h4)
  (assume h1, absurd h1 (not_mem_empty x)))

example : (A ∖ B) ∪ (A ∩ B) ∪ (B ∖ A) = A ∪ B := 
ext (take x, iff.intro 
  (λ h1, or.elim h1 
    (λ h2, or.elim h2 
      (λ ⟨h3, h4⟩, or.inl h3) 
      (λ ⟨h3, h4⟩, or.inl h3)) 
    (λ h2, or.inr h2^.left))
  (λ h1, or.elim h1
    (λ h2, or.elim (classical.em (x ∈ B)) 
      (λ h3, or.inl (or.inr ⟨h2, h3⟩)) 
      (λ h3, or.inl (or.inl ⟨h2, h3⟩)))
    (λ h2, or.elim (classical.em (x ∈ A)) 
      (λ h3, or.inl (or.inr ⟨h3, h2⟩)) 
      (λ h3, or.inr (⟨h2, h3⟩)))))

end

-- Exercise 3.1.11. Show that the axiom of replacement implies the axiom of 
-- specification.

-- Skipped. How do you express Tao's axiom of replacement in Lean
-- syntax?

-- Russell's Paradox -- Skipped

section 

universes u v w
variables {α : Type u} {β : α → Type v}

local infix ` ~ ` := function.equiv


-- Exercise 3.3.1. Show that the definition of function equality is reflexive,
-- symettric, and transitive

-- Lean's function equivalence definition: 
-- equiv (f₁ f₂ : π x : α, β x) : Prop := ∀ x, f₁ x = f₂ x

example (f : Π x : α, β x) : f ~ f := take x, rfl
example (f₁ f₂ : Π x : α, β x) : f₁ ~ f₂ → f₂ ~ f₁ := λ h x, eq.symm (h x)
example {f₁ f₂ f₃ : Π x: α, β x} : f₁ ~ f₂ → f₂ ~ f₃ → f₁ ~ f₃ :=
  λ h₁ h₂ x, eq.trans (h₁ x) (h₂ x)

end
-- substitution property: skipped

-- Exercise 3.3.2.
-- injectivity (f : α → β) : Prop := ∀ ⦃a₁ a₂⦄, f a₁ = f a₂ → a₁ = a₂
-- surjectivity (f : α → β) : Prop := ∀ b, ∃ a, f a = b
section

open function

universes u₁ u₂ u₃

variables {α : Type u₁} {β : Type u₂} {φ : Type u₃}

-- injectivity and function composition
example {g : β → φ} {f : α → β} (hg : injective g) (hf : injective f) : 
  injective (g ∘ f) :=
take a₁ a₂, assume h, hf (hg h)

-- surjectivity and function composition
example {g : β → φ} {f : α → β} (hg : surjective g) (hf : surjective f) 
  : surjective (g ∘ f) :=
λ (c : φ), exists.elim (hg c) (λ b hb, exists.elim (hf b) (λ a ha,
  exists.intro a (show g (f a) = c, from (eq.trans (congr_arg g ha) hb))))

-- Exercise 3.3.3: Skipped

-- Exercise 3.3.4. Cancellation laws for function composition

example (f₁ f₂ : α → β) (g₁ g₂ : β → φ) (h₁ : g₁ ∘ f₁ = g₁ ∘ f₂) 
  (hg : injective g₁) : f₁ = f₂ := 
funext (take x, 
  have h₂ : g₁ (f₁ x) = g₁ (f₂ x) → f₁ x = f₂ x, from @hg (f₁ x) (f₂ x), 
  have h₃ : _, from congr_fun h₁ x,
  h₂ (congr_fun h₁ x))

example (f : α → β) (g₁ g₂ : β → φ) (hf : surjective f) (h₁ : g₁ ∘ f = g₂ ∘ f) :
  g₁ = g₂ :=
funext (take y, 
  exists.elim (hf y) (take x hf₁,
    eq.rec (congr_fun h₁ x) hf₁))

-- Exercise 3.3.5. 
-- Exercise 3.3.6.
-- Exercise 3.3.7.
-- Exercise 3.3.8.
-- SKIPPED 

end
-- Exercise 3.4.1.
