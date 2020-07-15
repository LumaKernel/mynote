(*
以下を参考に
http://herb.h.kobe-u.ac.jp/coq/coq.pdf

*)

(* Require Import Ensembles. *)
(* 練習のため内容をそのまま移した *)
(* https://coq.inria.fr/library/Coq.Sets.Ensembles.html *)

Section Ensembles.
  Variable U : Type.

  Definition Ensemble := U -> Prop.

  Definition In (A:Ensemble) (x:U) : Prop := A x.

  Definition Included (B C:Ensemble) : Prop := forall x:U, In B x -> In C x.

  Inductive Empty_set : Ensemble :=.

  Inductive Full_set : Ensemble :=
    Full_intro : forall x:U, In Full_set x.

(* NB: The following definition builds-in equality of elements in U as Leibniz equality. *)
(* This may have to be changed if we replace U by a Setoid on U with its own equality eqs, with In_singleton: (y: U)(eqs x y) -> (In (Singleton x) y). *)

  Inductive Singleton (x:U) : Ensemble :=
    In_singleton : In (Singleton x) x.

  Inductive Union (B C:Ensemble) : Ensemble :=
    | Union_introl : forall x:U, In B x -> In (Union B C) x
    | Union_intror : forall x:U, In C x -> In (Union B C) x.

  Definition Add (B:Ensemble) (x:U) : Ensemble := Union B (Singleton x).

  Inductive Intersection (B C:Ensemble) : Ensemble :=
    Intersection_intro :
    forall x:U, In B x -> In C x -> In (Intersection B C) x.

  Inductive Couple (x y:U) : Ensemble :=
    | Couple_l : In (Couple x y) x
    | Couple_r : In (Couple x y) y.

  Inductive Triple (x y z:U) : Ensemble :=
    | Triple_l : In (Triple x y z) x
    | Triple_m : In (Triple x y z) y
    | Triple_r : In (Triple x y z) z.

  Definition Complement (A:Ensemble) : Ensemble := fun x:U => ~ In A x.

  Definition Setminus (B C:Ensemble) : Ensemble :=
    fun x:U => In B x /\ ~ In C x.

  Definition Subtract (B:Ensemble) (x:U) : Ensemble := Setminus B (Singleton x).

  Inductive Disjoint (B C:Ensemble) : Prop :=
    Disjoint_intro : (forall x:U, ~ In (Intersection B C) x) -> Disjoint B C.

  Inductive Inhabited (B:Ensemble) : Prop :=
    Inhabited_intro : forall x:U, In B x -> Inhabited B.

  Definition Strict_Included (B C:Ensemble) : Prop := Included B C /\ B <> C.

  Definition Same_set (B C:Ensemble) : Prop := Included B C /\ Included C B.

(* Extensionality Axiom *)

  Axiom Extensionality_Ensembles : forall A B:Ensemble, Same_set A B -> A = B.

End Ensembles.

Hint Unfold In Included Same_set Strict_Included Add Setminus Subtract: sets.

Hint Resolve Union_introl Union_intror Intersection_intro In_singleton
  Couple_l Couple_r Triple_l Triple_m Triple_r Disjoint_intro
  Extensionality_Ensembles: sets.

Require Import Classical.

Section MyClassical.
Variable A B: Prop.
Lemma Taiguu: (~B -> ~A) -> (A -> B).
Proof.
  intros.
  apply NNPP. (* 二重否定除去律 *)
  intro.
  specialize (H H1).
  contradiction.
Qed.

End MyClassical.


Section SetTheory.

Ltac ok := trivial;contradiction.
Ltac hairihou := apply NNPP; intro.

Variable U:Type.

Notation Shugo := (Ensemble U).

Notation "x ∈ A" := (In U A x) (at level 55, no associativity).
Notation "A ⊆ B" := (Included U A B) (at level 54, no associativity).
Notation "A ∩ B" := (Intersection U A B) (at level 53, right associativity).
Notation "A ∪ B" := (Union U A B) (at level 53, right associativity).
Notation φ := (Empty_set U).
Notation Ω := (Full_set U).


Lemma in_or_not: forall A, forall x, (x ∈A) \/ ~ (x ∈ A).
Proof.
  intros.
  apply classic.
Qed.

Print in_or_not. (* ここの classic って *)

Variable A B C D: Shugo.

Lemma bubun_transitive:
  (A ⊆ B) /\ (B ⊆ C) -> A ⊆ C.
Proof.
  unfold Included.
  intro.
  destruct H.
  intros.
  apply H0.
  apply H.
  trivial.
Qed.



Ltac bubun := unfold Included; intros.

Lemma empty_bubun: forall A, φ ⊆ A.
Proof.
  intros.
  bubun.
  destruct H. (* TODO : 何が起きているかよくわからない *)
Qed.

Lemma bubun_full: forall A, A ⊆ Ω.
Proof.
  intros.
  bubun.
  Print Full_intro.
  apply Full_intro.
Qed.

Print Ω.
Check Ω.
Print Full_set.
Check Full_set.
Eval simpl in Ω.
Compute Ω.


Print Extensionality_Ensembles.
Print Same_set.
Compute Ensemble U.
Check Same_set.

Check fun (U: Type) (a: U) => a.

(* 集合の同等性を示すための，タクティック *)

Ltac seteq := apply Extensionality_Ensembles; unfold Same_set; split.

Lemma union_id: (A∪A) = A.
Proof.
  apply Extensionality_Ensembles.
  unfold Same_set.
  split.
  bubun.
  Print Union_introl.
  Print In.
  destruct H.
  ok. ok.
  bubun.
  apply Union_introl.
  ok.
Qed.


Lemma union_comm: (A∪B) = (B∪A).
Proof.
  seteq.
  bubun.
  destruct H.
  apply Union_intror. ok.
  apply Union_introl. ok.
  bubun.
  destruct H.
  apply Union_intror. ok.
  apply Union_introl. ok.
Qed.

Lemma union_assoc: A∪(B∪C)=(A∪B)∪C.
Proof.
  seteq. bubun.
  destruct H.
  apply Union_introl.
  apply Union_introl. ok.
  bubun.
  destruct H.
  apply Union_introl.
  apply Union_intror. ok.
  apply Union_intror. ok.
  bubun.
  destruct H.
  destruct H.
  apply Union_introl. ok.
  apply Union_intror.
  apply Union_introl. ok.
  apply Union_intror.
  apply Union_intror. ok.
Qed.


Lemma union_includedl: A ⊆ A∪B.
Proof.
  bubun.
  apply Union_introl. ok.
Qed.

Lemma union_includedr: B ⊆ A∪B.
Proof.
  bubun.
  apply Union_intror. ok.
Qed.

Lemma union_intro: A ⊆ C /\ B ⊆ C -> A ∪ B ⊆ C.
Proof.
  intros.
  bubun.
  destruct H.
  unfold Included in H.
  unfold Included in H1.
  destruct H0.
  apply H in H0. ok.
  apply H1 in H0. ok.
Qed.

Lemma Kuu: Disjoint U A B <-> (A ∩ B) = φ.
Proof.
  split.
  -
  intros.
  destruct H. (* TODO : なぜ? *)
  seteq.
  --
  bubun.
  Print Disjoint.
  specialize (H x). ok.
  --
  bubun.
  specialize (H x). ok.
  -
  intros.
  apply Disjoint_intro. (* NOTE : ここはわかる *)
  intros.
  intro.
  rewrite -> H in H0.
  destruct H0. (* TODO : ⊆に対する destruct ってなに? *)
Qed.

(* A.6 *)

Lemma set_distribute_or: A∪(B∩C) = (A∪B)∩(A∪C).
Proof.
  seteq.
  -
  bubun.
  destruct H.
  --
  apply Intersection_intro.
  ---
  apply Union_introl. ok.
  ---
  apply Union_introl. ok.
  --
  destruct H.
  apply Intersection_intro.
  ---
  apply Union_intror. ok.
  ---
  apply Union_intror. ok.
  -
  bubun.
  destruct H.
  destruct H.
  --
  apply Union_introl. ok.
  --
  destruct H0.
  ---
  apply Union_introl. ok.
  ---
  apply Union_intror.
  apply Intersection_intro. ok. ok.
Qed.

Lemma set_distribute_and: A∩(B∪C) = (A∩B)∪(A∩C).
Proof.
  seteq.
  -
  bubun.
  destruct H.
  destruct H0.
  --
  apply Union_introl.
  apply Intersection_intro.
  --- ok.
  --- ok.
  --
  apply Union_intror.
  apply Intersection_intro.
  --- ok.
  --- ok.
  -
  bubun.
  destruct H.
  destruct H.
  --
  apply Intersection_intro. ok.
  apply Union_introl. ok.
  --
  destruct H.
  ---
  apply Intersection_intro. ok.
  apply Union_intror. ok.
Qed.

Lemma set_absorption_or_and: A∪(A∩B) = A.
Proof.
  seteq.
  -
  bubun.
  destruct H. ok.
  destruct H. ok.
  -
  bubun.
  apply Union_introl. ok.
Qed.

Lemma set_absorption_and_or: A∩(A∪B) = A.
Proof.
  seteq.
  -
  bubun.
  destruct H. ok.
  -
  bubun.
  apply Intersection_intro.
  -- ok.
  --
  apply Union_introl. ok.
Qed.

(* 問題 A.7 *)

Lemma A7R: A⊆B -> B⊆C -> A∪B=B∩C.
Proof.
  intros.
  unfold Included in H.
  unfold Included in H0.
  seteq.
  -
  bubun.
  destruct H1.
  --
  apply Intersection_intro.
  specialize (H x). auto. (* これくらいはやってくれるんだな *)
  specialize (H x). auto.
  --
  apply Intersection_intro. ok.
  auto. (* specialize もやってくれる！ *)
  -
  bubun.
  destruct H1.
  apply Union_intror. auto.
Qed.



Lemma A7L: A∪B=B∩C -> A⊆B /\ B⊆C.
Proof.
  intros.
  split.
  bubun.
  assert (x ∈ A ∪ B).
  apply Union_introl. auto.
  rewrite -> H in H1.
  destruct H1. auto.
  bubun.
  assert (x ∈ A ∪ B).
  apply Union_intror. auto.
  rewrite H in H1.
  destruct H1.
  auto.
Qed.

Notation "A \ B" := (Setminus U A B) (at level 60, no associativity).

Lemma setminus: forall x,
  (x ∈ A) -> (~(x ∈ B) -> (x ∈ (A\B))).
Proof.
  intros.
  unfold In.
  unfold Setminus.
  split.
  - auto.
  - auto.
Qed.

About "=".
About eq.

Lemma probA8: ((A \ B) ∪ (A∩B)) = A.
Proof.
  seteq.
  bubun.
  destruct H.
  destruct H. auto. (* TODO : ここの destruct なに *)
  destruct H. auto.
  bubun.
  Print in_or_not.
  destruct (in_or_not B x).
  -
  apply Union_intror.
  apply Intersection_intro. auto. auto.
  -
  apply Union_introl.
  
  (* split が適用されるとき，以下のような自明な unfold が行われていると考えていい？ *)
  unfold In.
  unfold Setminus.
  
  split. auto. auto.
Qed.

(* 練習問題は後でやるか，パス *)

Variable K:Type.
Definition Fam := K -> Shugo.

Inductive UnionF (X:Fam): Shugo :=
  unionf_intro: forall x:U,
    (exists n:K, (x ∈ (X n))) -> x ∈ (UnionF X).

Inductive InterF (X:Fam): Shugo :=
  interf_intro: forall x:U,
    (forall n:K, (x ∈ (X n))) -> x ∈ (InterF X).


Lemma mem_unionf: forall F:Fam, forall n:K,
  ((F n) ⊆ UnionF F).
Proof.
  intros.
  bubun.
  apply unionf_intro.
  exists n. auto.
Qed.

Lemma mem_interf: forall F:Fam, forall n:K,
  ((InterF F) ⊆ (F n)).
Proof.
  intros.
  bubun.
  destruct H.
  auto.
Qed.

(* TODO : destruct するときにマッチするものが2つあるとどうなるか *)

End SetTheory.

Ltac ok:=trivial;contradiction.
Ltac hairihou:=apply NNPP;intro.
Ltac seteq:=apply Extensionality_Ensembles;unfold Same_set; split.
Ltac bubun:=unfold Included;intros.
Notation "x ∈ A":=(In _ A x)(at level 50,no associativity).
Notation "A ⊆ B":=(Included _ A B)(at level 60,no associativity).
Notation "A ∪ B" :=(Union _ A B)(at level 62, right associativity).
Notation "A ∩ B":=(Intersection _ A B)(at level 64, right associativity).





















