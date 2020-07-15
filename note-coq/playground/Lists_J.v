Add LoadPath "~/mystudy/Coq入門".
(* Require Import Basics_J. *)
Require Import Unicode.Utf8_core.

Module NatList.

Inductive natprod : Type :=
  pair : nat → nat → natprod.

Definition fst (p : natprod) : nat :=
  match p with
  | pair x y => x
  end.
Definition snd (p : natprod) : nat :=
  match p with
  | pair x y => y
  end.


Notation "( x , y )" := (pair x y).


Eval simpl in (fst (3,4)).

Definition fst' (p : natprod) : nat :=
  match p with
  | (x,y) => x
  end.
Definition snd' (p : natprod) : nat :=
  match p with
  | (x,y) => y
  end.

Definition swap_pair (p : natprod) : natprod :=
  match p with
  | (x,y) => (y,x)
  end.

Theorem surjective_pairing' : ∀ (n m : nat),
  (n,m) = (fst (n,m), snd (n,m)).
Proof.
  reflexivity. Qed.

Theorem surjective_pairing : ∀ (p : natprod),
  p = (fst p, snd p).
Proof.
  intros p. destruct p as (n, m). simpl. reflexivity. Qed.

Theorem snd_fst_is_swap : ∀ (p : natprod),
  (snd p, fst p) = swap_pair p.
Proof.
  destruct p. simpl. auto.
Qed.

Inductive natlist : Type :=
  | nil : natlist
  | cons : nat → natlist → natlist.


Definition l_123 := cons 1 (cons 2 (cons 3 nil)).

Notation "x :: l" := (cons x l) (at level 60, right associativity).
Notation "[ ]" := nil.
Notation "[ x , .. , y ]" := (cons x .. (cons y nil) ..).

Fixpoint repeat (n count : nat) : natlist :=
  match count with
  | O => nil
  | S count' => n :: (repeat n count')
  end.

Fixpoint length (l:natlist) : nat :=
  match l with
  | nil => O
  | h :: t => S (length t)
  end.

Fixpoint app (l1 l2 : natlist) : natlist :=
  match l1 with
  | nil => l2
  | h :: t => h :: (app t l2)
  end.

Notation "x ++ y" := (app x y)
                     (right associativity, at level 60).

Example test_app1: [1,2,3] ++ [4,5] = [1,2,3,4,5].
Proof. reflexivity. Qed.
Example test_app2: nil ++ [4,5] = [4,5].
Proof. reflexivity. Qed.
Example test_app3: [1,2,3] ++ nil = [1,2,3].
Proof. reflexivity. Qed.

Definition hd (default:nat) (l:natlist) : nat :=
  match l with
  | nil => default
  | h :: t => h
  end.

Definition tail (l:natlist) : natlist :=
  match l with
  | nil => nil
  | h :: t => t
  end.

Example test_hd1: hd 0 [1,2,3] = 1.
Proof. reflexivity. Qed.
Example test_hd2: hd 0 [] = 0.
Proof. reflexivity. Qed.
Example test_tail: tail [1,2,3] = [2,3].
Proof. reflexivity. Qed.


(*
練習問題: ★★, recommended (list_funs)
以下の nonzeros、 oddmembers、 countoddmembers の定義を完成させなさい。
*)

Fixpoint nonzeros (l:natlist) : natlist :=
   match l with
   | nil => nil
   | x::xs => match x with
     | 0 => nonzeros xs
     | _ => x::(nonzeros xs)
     end
   end.

Example test_nonzeros: nonzeros [0,1,0,2,3,0,0] = [1,2,3].
Proof. reflexivity. Qed.

Fixpoint odd (x:nat) :=
  match x with
  | O => false
  | S x' => even x'
  end
with even (x:nat) :=
  match x with
  | O => true
  | S x' => odd x'
  end.

Fixpoint oddmembers (l:natlist) : natlist :=
   match l with
   | nil => nil
   | x::xs => match odd x with
     | true => x::(oddmembers xs)
     | false => oddmembers xs
     end
   end.

Example test_oddmembers: oddmembers [0,1,0,2,3,0,0] = [1,3].
Proof. reflexivity. Qed.

Fixpoint countoddmembers (l:natlist) : nat :=
   length (oddmembers l).

Example test_countoddmembers1: countoddmembers [1,0,3,1,4,5] = 4.
Proof. reflexivity. Qed.
Example test_countoddmembers2: countoddmembers [0,2,4] = 0.
Proof. reflexivity. Qed.
Example test_countoddmembers3: countoddmembers nil = 0.
Proof. reflexivity. Qed.

Fixpoint alternate (l1 l2 : natlist) : natlist :=
  match l1 with
  | nil => l2
  | x::xs => match l2 with
    | nil => x::xs
    | y::ys => x::y::(alternate xs ys)
    end
  end.

Example test_alternate1: alternate [1,2,3] [4,5,6] = [1,4,2,5,3,6].
Proof. reflexivity. Qed.
Example test_alternate2: alternate [1] [4,5,6] = [1,4,5,6].
Proof. reflexivity. Qed.
Example test_alternate3: alternate [1,2,3] [4] = [1,4,2,3].
Proof. reflexivity. Qed.
Example test_alternate4: alternate [] [20,30] = [20,30].
Proof. reflexivity. Qed.

Definition bag := natlist. (* multiset *)

Fixpoint eq_b (n m:nat) :=
  match n with
  | O => match m with
    | O => true
    | _ => false
    end
  | S n' => match m with
    | O => false
    | S m' => eq_b n' m'
    end
  end.

Lemma eq_b_is_eq: forall n m : nat, n = m <-> eq_b n m = true.
Proof.
  split.
  intros.
  induction n. rewrite <- H. auto.
  Admitted.

Fixpoint count (v:nat) (s:bag) : nat :=
  match s with
  | nil => O
(*   | v::xs => S(count v xs) (* vが変数扱いされてダメなのか *) *)
  | x::xs => match eq_b x v with
    | true => S(count v xs)
    | false => count v xs
    end
  end.


Example test_count1: count 1 [1,2,3,1,4,1] = 3.
Proof. reflexivity. Qed.
Example test_count2: count 6 [1,2,3,1,4,1] = 0.
Proof. reflexivity. Qed.

Definition sum : bag → bag → bag :=
   alternate.

Example test_sum1: count 1 (sum [1,2,3] [1,4,1]) = 3.
Proof. reflexivity. Qed.

Definition add (v:nat) (s:bag) : bag :=
   sum [v] s.

Example test_add1: count 1 (add 1 [1,4,1]) = 3.
Proof. auto. Qed.
Example test_add2: count 5 (add 1 [1,4,1]) = 0.
Proof. auto. Qed.

Fixpoint lt_b n m :=
  match n with
  | O => true
  | S n' => match m with
    | O => false
    | S m' => lt_b n' m'
    end
  end.

Definition member (v:nat) (s:bag) : bool :=
   lt_b 1 (count v s).

Example test_member1: member 1 [1,4,1] = true.
Proof. auto. Qed.
Example test_member2: member 2 [1,4,1] = false.
Proof. auto. Qed.

(*
練習問題: ★★★, optional (bag_more_functions)
練習として、さらにいくつかの関数を作成してください。
*)

Fixpoint remove_one (v:nat) (s:bag) : bag :=
  match s with
  | nil => nil
  | x::xs => match eq_b v x with
    | true => xs
    | false => x::(remove_one v xs)
    end
  end.

Example test_remove_one1: count 5 (remove_one 5 [2,1,5,4,1]) = 0.
Proof. auto. Qed.
Example test_remove_one2: count 5 (remove_one 5 [2,1,4,1]) = 0.
Proof. auto. Qed.
Example test_remove_one3: count 4 (remove_one 5 [2,1,4,5,1,4]) = 2.
Proof. auto. Qed.
Example test_remove_one4:
  count 5 (remove_one 5 [2,1,5,4,5,1,4]) = 1.
Proof. auto. Qed.

Fixpoint remove_all (v:nat) (s:bag) : bag :=
   match s with
   | nil => nil
   | x::xs => match eq_b v x with
     | true => remove_all v xs
     | false => x::(remove_all v xs)
     end
   end.

Example test_remove_all1: count 5 (remove_all 5 [2,1,5,4,1]) = 0.
Proof. auto. Qed.
Example test_remove_all2: count 5 (remove_all 5 [2,1,4,1]) = 0.
Proof. auto. Qed.
Example test_remove_all3: count 4 (remove_all 5 [2,1,4,5,1,4]) = 2.
Proof. auto. Qed.
Example test_remove_all4: count 5 (remove_all 5 [2,1,5,4,5,1,4,5,1,4]) = 0.
Proof. auto. Qed.

Fixpoint subset (s1:bag) (s2:bag) : bool :=
  match s1 with
  | nil => true
  | x::xs => match count x s2 with
    | O => false
    | _ => subset xs (remove_one x s2)
    end
  end.

Example test_subset1: subset [1,2] [2,1,4,1] = true.
Proof. auto. Qed.
Example test_subset2: subset [1,2,2] [2,1,4,1] = false.
Proof. auto. Qed.

(*

練習問題: ★★★, recommended (bag_theorem)
count や add を使ったバッグに関する面白い定理書き、それを証明しなさい。この問題はいわゆる自由課題で、真になることがわかっていても、証明にはまだ習っていない技を使わなければならない定理を思いついてしまうこともあります。証明に行き詰まってしまったら気軽に質問してください。

*)

(* うｗ *)

Lemma remall: forall (x : nat) (s : natlist),
  count x (remove_all x s) = 0.
Proof.
  intros.
  induction s.
  - (* s = nil *)
    simpl. reflexivity.
  - (* s = x::xs *)
    simpl.
    destruct (eq_b x n).
    -- (* eq_b x n = true *)
      rewrite IHs. reflexivity.
    -- (* eq_b x n = false *)
      Admitted. (* TODO : eq_b x n = false が仮定にないのはなぜ… *)

Theorem nil_app : ∀ l:natlist,
  [] ++ l = l.
Proof.
   reflexivity. Qed.


Theorem tl_length_pred : ∀ l:natlist,
  pred (length l) = length (tail l).
Proof.
  intros l. destruct l as [| n l'].
  -
    reflexivity.
  -
    reflexivity. Qed.

Theorem app_ass : ∀ l1 l2 l3 : natlist,
  (l1 ++ l2) ++ l3 = l1 ++ (l2 ++ l3).
Proof.
  intros l1 l2 l3. induction l1 as [| n l1'].
  -
    reflexivity.
  -
    simpl. rewrite -> IHl1'. reflexivity. Qed.

Theorem app_length : ∀ l1 l2 : natlist,
  length (l1 ++ l2) = (length l1) + (length l2).
Proof.
  intros l1 l2. induction l1 as [| n l1'].
  -
    reflexivity.
  -
    simpl. rewrite -> IHl1'. reflexivity. Qed.

Fixpoint snoc (l:natlist) (v:nat) : natlist :=
  match l with
  | nil => [v]
  | h :: t => h :: (snoc t v)
  end.


Fixpoint rev (l:natlist) : natlist :=
  match l with
  | nil => nil
  | h :: t => snoc (rev t) h
  end.

Example test_rev1: rev [1,2,3] = [3,2,1].
Proof. reflexivity. Qed.
Example test_rev2: rev nil = nil.
Proof. reflexivity. Qed.


Theorem length_snoc : ∀ n : nat, ∀ l : natlist,
  length (snoc l n) = S (length l).
Proof.
  intros n l. induction l as [| n' l'].
  -
    reflexivity.
  -
    simpl. rewrite -> IHl'. reflexivity. Qed.


Theorem rev_length : ∀ l : natlist,
  length (rev l) = length l.
Proof.
  intros l. induction l as [| n l'].
  -
    reflexivity.
  -
    simpl. rewrite -> length_snoc.
    rewrite -> IHl'. reflexivity. Qed.

SearchAbout rev.

(*
練習問題: ★★★, recommended (list_exercises)
リストについてさらに練習しましょう。

*)

Theorem app_nil_end : ∀ l : natlist,
  l ++ [] = l.
Proof.
  intros.
  induction l.
  - reflexivity.
  - simpl. rewrite IHl. reflexivity.
Qed.

Lemma rev_snoc: forall (x : nat) (l : natlist),
  rev (snoc l x) = x:: rev l.
Proof.
  intros.
  induction l.
  -
    simpl. reflexivity.
  -
    simpl. rewrite IHl.
    simpl. reflexivity.
Qed.

Theorem rev_involutive : ∀ l : natlist,
  rev (rev l) = l.
Proof.
  induction l.
  -
    reflexivity.
  -
    simpl.
    rewrite rev_snoc.
    rewrite IHl. reflexivity.
Qed.

Lemma snoc_app: forall (l1 l2 : natlist) (x : nat),
  snoc (l1 ++ l2) x = l1 ++ snoc l2 x.
Proof.
  intros.
  induction l1.
  -
    reflexivity.
  -
    simpl.
    rewrite IHl1.
    reflexivity.
Qed.

Theorem distr_rev : ∀ l1 l2 : natlist,
  rev (l1 ++ l2) = (rev l2) ++ (rev l1).
Proof.
  intros.
  induction l1.
  -
    simpl.
    SearchAbout ([]).
    rewrite app_nil_end.
    reflexivity.
  -
    simpl.
    rewrite IHl1.
    rewrite snoc_app.
    reflexivity.
Qed.


(*
次の問題には簡単な解法があります。こんがらがってしまったようであれば、少し戻って単純な方法を探してみましょう。
*)

Theorem app_ass4 : ∀ l1 l2 l3 l4 : natlist,
  l1 ++ (l2 ++ (l3 ++ l4)) = ((l1 ++ l2) ++ l3) ++ l4.
Proof.



Theorem snoc_append : ∀ (l:natlist) (n:nat),
  snoc l n = l ++ [n].
Proof.
    





































