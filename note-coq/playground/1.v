(* https://employment.en-japan.com/engineerhub/entry/2018/08/10/110000 *)

Require Import List.
Import ListNotations.

Fixpoint reverse {A : Type} (xs : list A) :=
  match xs with
  | nil => nil
  | x :: xs' =>
    reverse xs' ++ [x]
  end.

Compute reverse [1;2;3].

Lemma reverse_append : forall (A: Type) (xs ys: list A),
  reverse (xs ++ ys) = reverse ys ++ reverse xs.
Proof.
  intros.
  induction xs.
  - simpl.
  SearchRewrite(_ ++ []).
  rewrite app_nil_r.
  reflexivity.
  - simpl.
  rewrite IHxs.
  SearchRewrite (_ ++ _ ++ _).
  rewrite app_assoc_reverse.
  reflexivity.
Qed.

Theorem reverse_reverse : forall (A: Type) (xs : list A),
  reverse (reverse xs) = xs.
Proof.
  intros A xs.
  induction xs.
  -
  simpl.
  reflexivity.
  -
  simpl.
  SearchRewrite (reverse _ ++ _).
  rewrite reverse_append.
  rewrite IHxs.
  simpl.
  reflexivity.
Qed.

Require Extraction.
Extraction Language OCaml.
Extraction "reverse.ml" reverse.
