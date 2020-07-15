(*

引き続き，以下を参考に
http://herb.h.kobe-u.ac.jp/coq/coq.pdf

*)

(*

TODO 現時点わかっていないこと．
- 前提部に対する destruct, それと CiCの関係?
- Hintとかってどういう意味

*)

Add LoadPath "~/mystudy/Coq入門".


Require Import Shugo.

Print Shugo.

Section Image.

(* https://coq.inria.fr/refman/language/gallina-extensions.html#coq:flag.implicit-arguments *)


Variable U V: Type.
Notation UShugo:= (Ensemble U).
Notation VShugo:= (Ensemble V).

Set Implicit Arguments.

Inductive Im (X: UShugo) (f: U -> V) : VShugo :=
  Im_intro: forall x:U, x ∈ X ->
    forall y:V, y = f x -> (f x) ∈(Im X f).

Inductive InvIm (Y: VShugo) (f: U -> V) : UShugo :=
  InvIm_intro: forall x:U,
    (f x) ∈ Y -> x ∈ (InvIm Y f).

(* NOTE : Notationを定義するときは，空白を開けて token が区切られていることを明確にする *)
Notation "f [ X ]" := (Im X f) (at level 40).
Notation "f -[ X ]" := (InvIm X f) (at level 40).


Theorem Im_def: forall (X: UShugo) (f: U->V) (x:U), x ∈ X -> f x ∈ f[X].
Proof.
  intros.
  specialize(Im_intro X f x H).
  intros.
  specialize (H0 (f x)).
  apply H0. ok.
Qed.


Theorem Im_element: forall (X:UShugo) (f:U->V) (y:V),
  y∈f[X] <-> exists x:U, x∈X /\ y = f(x).
Proof.
  split.
  -
  intros.
  destruct H.
  exists x.
  split. ok. ok.
  -
  intros.
  destruct H.
  destruct H.
  specialize(Im_def X f x H).
  rewrite H0. ok.
Qed.

(* 定理 A.5 *)

Lemma Im_subset: forall (f:U->V) (A B: UShugo),
  A⊆B -> f[A]⊆f[B].
Proof.
  intros.
  bubun.
  unfold Included in H.
  destruct H0.
  specialize(H x).
  specialize(H H0).
  specialize(Im_def B f x H).
  trivial.
Qed.

Lemma intrusion_or: forall (f:U->V) (A B: UShugo),
  f[A∪B] = f[A]∪f[B].
Proof.
  intros.
  seteq.
  - bubun.
  destruct H.
  destruct H.
  --
  apply Union_introl.
  specialize(Im_element A f y).
  intros.
  destruct H1.
  rewrite <- H0.
  apply H2.
  exists x.
  auto.
  --
  apply Union_intror.
  specialize(Im_element B f y).
  intros.
  destruct H1.
  rewrite <- H0.
  apply H2.
  exists x.
  auto.
  -
  Search((_ ∪ _) ⊆ _).
  apply union_intro.
  split.
  apply Im_subset.
  Search(_ ⊆ (_ ∪ _)).
  apply union_includedl.
  apply Im_subset.
  apply union_includedr.
Qed.


(* 逆像の性質 *)

Lemma InvIm_def: forall (Y:VShugo) (x:U) (f:U->V),
  (x ∈ f-[Y]) <-> (f x ∈ Y).
Proof.
  intros.
  split.
  -
  intro.
  destruct H.
  auto.
  -
  intro.
  apply InvIm_intro. auto.
Qed.

Notation UU := (Full_set U).

Lemma InvImSet: forall (Y:VShugo) (f:U -> V),
  f-[Y] = f-[f[UU] ∩ Y].
Proof.
  intros.
  seteq.
  -
  bubun.
  destruct H.
  apply InvIm_def.
  split.
  --
  apply Im_def.
  Search(_ ∈ Full_set _).
  apply Full_intro.
  -- auto.
  -
  bubun.
  destruct H.
  apply InvIm_def.
  remember (f x) as y.
  destruct H. auto.
Qed.

Lemma InvIm_subset: forall (A B: VShugo) (f: U->V),
  A⊆B -> f-[A] ⊆ f-[B].
Proof.
  intros.
  bubun.
  apply InvIm_def.
  destruct H0.
  remember (f x) as y.
  Search (_ ⊆ _).
  unfold Included in H.
  specialize(H y H0). auto. (* TODO : specialize 何を渡せばいいのかよくわかっていない *)
Qed.

End Image.

(* 関係 *)

Section Relation.

Variable U: Type.
Definition Relation := U -> U -> Prop.

Definition Reflexive (R: Relation): Prop :=
  forall x:U, R x x.

Definition Symmetric (R: Relation): Prop :=
  forall (x y : U), R x y -> R y x.

Definition Transitive (R: Relation): Prop :=
  forall (x y z : U), R x y /\ R y z -> R x z.


Definition Equivalent_Relation (R: Relation): Prop :=
  Reflexive(R) /\ Symmetric(R) /\ Transitive(R).

Notation Shugo := (Ensemble U).
Variable R: Relation.

Hypothesis equiv: Equivalent_Relation R.

Ltac eqrel := destruct equiv as [ref symtran];
              destruct symtran as [sym tran].

Inductive Equiv_class (x:U): Shugo :=
  eqclass_intro: forall y: U, R x y -> y ∈ (Equiv_class x).

Notation "[ x ]" := (Equiv_class x).

Lemma equivclass_id: forall x:U, x ∈ [x].
Proof.
  intro.
  apply eqclass_intro.
  eqrel.
  apply ref.
Qed.

Lemma equivclass_rel: forall x y: U, R x y -> [x]⊆[y].
Proof.
  intros.
  bubun.
  destruct H0.
  apply eqclass_intro.
  eqrel. apply sym.
  specialize(tran y0 x y).
  apply sym in H0. auto.
Qed.


Lemma equivclass_eq: forall x y: U, R x y -> [x] = [y].
Proof.
  intros.
  seteq.
  bubun. destruct H0.
  Search ([_]).
  Print eqclass_intro.
  apply eqclass_intro.
  eqrel.
  specialize(tran y x y0).
  apply sym in H. auto.
  bubun. destruct H0.
  Search ([_]).
  Print eqclass_intro.
  apply eqclass_intro.
  eqrel.
  specialize(tran x y y0).
  apply sym in H. auto.
Qed.

Lemma DNI: forall p: Prop, p -> ~~ p.
Proof. auto. Qed.

Lemma equivclass_exclusive: forall x y: U, ~ R x y -> [x] ∩ [y] = Empty_set U.
Proof.
  intros.
  Search(_ = Empty_set _).
  apply Kuu.
  Search Disjoint.
  apply Disjoint_intro.
  intros.
  hairihou.
  Search (~~_).
  apply Classical_Prop.NNPP in H0.
  destruct H0.
  destruct H0.
  destruct H1.
  eqrel.
  apply sym in H1.
  specialize(tran x y0 y).
  auto.
Qed.

Definition EqFam x := [x].
Check EqFam.
Print EqFam.

Print Fam.
Search Fam.

Lemma EqUnion : UnionF _ _ EqFam = Full_set U.
Proof.
  seteq.
  -
  bubun.
  destruct H.
  apply Full_intro.
  -
  bubun.
  apply unionf_intro.
  exists x.
  Search(_∈[_]).
  apply equivclass_id.
Qed.



































