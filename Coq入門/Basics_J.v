(* https://coq.github.io/doc/master/stdlib/Coq.Unicode.Utf8_core.html *)
Require Import Unicode.Utf8_core.

Inductive day : Type :=
  | monday : day
  | tuesday : day
  | wednesday : day
  | thursday : day
  | friday : day
  | saturday : day
  | sunday : day.

Inductive month: Type :=
  | Jan : month.

Definition next_weekday (d: day): day :=
  match d with
  | monday => tuesday
  | tuesday => wednesday
  | wednesday => thursday
  | thursday => friday
  | friday => monday
  | saturday => monday
  | sunday => monday
  end.

Compute next_weekday monday.
Eval simpl in (next_weekday friday).
Eval simpl in (next_weekday (next_weekday saturday)).

Example test_next_weekday:
  (next_weekday (next_weekday saturday)) = tuesday.
Proof.
  simpl. reflexivity.
Qed.

Inductive bool: Type :=
  | true  : bool
  | false : bool.


Definition negb (b:bool): bool :=
  match b with
  | true => false
  | false => true
  end.


Definition andb (b1 b2 : bool) : bool :=
  match b1 with
  | true  => b2
  | false => false
  end.

Definition orb (b1 b2 : bool) : bool :=
  match b1 with
  | true => true
  | false => b2
  end.

Example test_orb1: (orb true false) = true.
Proof. simpl. reflexivity. Qed.

Example test_orb2: (orb false false) = false.
Proof. simpl. reflexivity. Qed.

Example test_orb3: (orb false true) = true.
Proof. simpl. reflexivity. Qed.

Example test_orb4: (orb true false) = true.
Proof. simpl. reflexivity. Qed.


Definition admit {T: Type} : T. Admitted.
Check admit.

Definition nandb (b1 b2: bool) : bool :=
  admit.

Example test_nandb1: (nandb true false) = true.
Admitted.
Example test_nandb2: (nandb false false) = true.
Admitted.
Example test_nandb3: (nandb false true) = true.
Admitted.
Example test_nandb4: (nandb true true) = false.
Admitted.


Definition andb3 (b1:bool) (b2:bool) (b3:bool) : bool :=
   admit.

Example test_andb31: (andb3 true true true) = true.
Admitted.
Example test_andb32: (andb3 false true true) = false.
Admitted.
Example test_andb33: (andb3 true false true) = false.
Admitted.
Example test_andb34: (andb3 true true false) = false.
Admitted.


(* Checkで型を確認 *)

Check (negb true).
Check negb.
Check admit.


Module Playground1.

Inductive nat: Type :=
  | O : nat
  | S : nat -> nat.

End Playground1.

Definition minustwo (n: nat): nat :=
  match n with
  | O => O
  | S O => O
  | S (S n') => n'
  end.


Check S (S (S (S O))).
Eval simpl in (minustwo 4).

Check S.
Check pred.
Check minustwo.


Fixpoint evenb (n: nat): bool :=
  match n with
  | O => true
  | S O => false
  | S (S n') => evenb n'
  end.


(* Definition oddb (n: nat): nat := negb (evenb n). *)
(* 型推論すげー *)
Definition oddb n := negb (evenb n).

Example test_oddb1: (oddb (S O)) = true.
Proof. simpl. reflexivity. Qed.
Example test_oddb2: (oddb (S (S (S (S O))))) = false.
Proof. simpl. reflexivity. Qed.


Module Playground2.
Fixpoint plus n m : nat :=
  match n with
  | O => m
  | S n' => S (plus n' m)
  end.
Eval simpl in (plus (S (S (S O))) (S (S O))).

Check plus.

Fixpoint mult n m : nat :=
  match n with
  | O => O
  | S n' => plus m (mult n' m)
  end.


Fixpoint minus n m : nat :=
  match n, m with
  | O, _ => O
  | S _, O => n
  | S n', S m' => minus n' m'
  end.

End Playground2.

Fixpoint exp (base power : nat) : nat :=
  match power with
  | O => S O
  | S p => mult base (exp base p)
  end.

Example test_mult1: mult 3 3 = 9.
Proof. simpl. reflexivity. Qed.

Fixpoint factorial (n:nat) : nat :=
  match n with
  | O => S O
  | S n' => mult n (factorial n')
  end.

Example test_factorial1: (factorial 3) = 6.
Proof. auto. Qed.
Example test_factorial2: (factorial 5) = (mult 10 12).
Proof. auto. Qed.


Notation "x + y" := (plus x y) (at level 50, left associativity) : nat_scope.
Notation "x - y" := (minus x y) (at level 50, left associativity) : nat_scope.
Notation "x * y" := (mult x y) (at level 40, left associativity) : nat_scope.

Check ((0 + 1) + 1).
Check Type.
Check nat.
Check Set.

Compute (nat*nat)%type.

Fixpoint beq_nat (n m : nat) : bool :=
  match n with
  | O => match m with
         | O => true
         | S m' => false
         end
  | S n' => match m with
            | O => false
            | S m' => beq_nat n' m'
            end
  end.

Fixpoint ble_nat (n m : nat) : bool :=
  match n with
  | O => true
  | S n' =>
      match m with
      | O => false
      | S m' => ble_nat n' m'
      end
  end.

Example test_ble_nat1: (ble_nat 2 2) = true.
Proof. simpl. reflexivity. Qed.
Example test_ble_nat2: (ble_nat 2 4) = true.
Proof. simpl. reflexivity. Qed.
Example test_ble_nat3: (ble_nat 4 2) = false.
Proof. simpl. reflexivity. Qed.


Fixpoint blt_nat (n m : nat) : bool :=
  match n with
  | O =>
    match m with
    | O => false
    | _ => true
    end
  | S n' =>
    match m with
    | O => false
    | S m' => blt_nat n' m'
    end
  end.

Example test_blt_nat1: (blt_nat 2 2) = false.
Proof. auto. Qed.
Example test_blt_nat2: (blt_nat 2 4) = true.
Proof. auto. Qed.
Example test_blt_nat3: (blt_nat 4 2) = false.
Proof. auto. Qed.

Theorem plus_O_n' : forall n:nat, 0 + n = n.
Proof.
  reflexivity. Qed.

Eval simpl in (forall n:nat, n + 0 = n).
Eval simpl in (forall n:nat, 0 + n = n).

Theorem plus_O_n'' : forall n:nat, 0 + n = n.
Proof.
  intros n. reflexivity. Qed.

Theorem plus_1_l : forall n:nat, 1 + n = S n.
Proof.
  intros n.
  Info 3 reflexivity. Qed.

Theorem mult_0_l : forall n:nat, 0 * n = 0.
Proof.
  intros n. reflexivity. Qed.

Theorem plus_id_example: forall n m : nat,
  n = m -> n + n = m + m.
Proof.
  intros n m.
  intros H.
  rewrite -> H.
  reflexivity.
Qed.


(* 練習問題 x *)
Theorem plus_id_exercise : ∀ n m o : nat,
  n = m → m = o → n + m = m + o.
Proof.
  intros.
  rewrite H.
  rewrite H0.
  reflexivity.
Qed.

Theorem mult_0_plus : ∀ n m : nat,
  (0 + n) * m = n * m.
Proof.
  intros n m.
  rewrite -> plus_O_n.
  reflexivity. Qed.

(* 練習問題 xx *)
Theorem mult_1_plus : ∀ n m : nat,
  (1 + n) * m = m + (n * m).
Proof.
  intros.
  simpl.
  reflexivity.
Qed.

Theorem plus_1_neq_0 : ∀ n : nat,
  beq_nat (n + 1) 0 = false.
Proof.
  intros n. simpl.
(*   destruct n as [| n']. *) (* as いらなさそうだよね *)
  destruct n.
  simpl. reflexivity.
  simpl.
(*
なぜ beq_nat (plus n (S 0)) 0 だと簡約化できなくて，
beq_nat (plus (S n) (S 0)) 0 だと簡約化できたのか．
S だとわかっているから，
S (plus S n (S 0)) へと simplify されます
beq_nat の match にひっかかります，ってかんじか
*)
reflexivity.
Qed.

Theorem negb_involutive : ∀ b : bool,
  negb (negb b) = b.
Proof.
  intros b. destruct b.
    reflexivity.
    reflexivity. Qed.


Theorem zero_nbeq_plus_1 : ∀ n : nat,
  beq_nat 0 (n + 1) = false.
Proof.
  intros.
  simpl.
  destruct n.
  reflexivity.
  reflexivity.
Qed.


Require String. Open Scope string_scope.

Ltac move_to_top x :=
  match reverse goal with
  | H : _ |- _ => try move x after H
  end.

Tactic Notation "assert_eq" ident(x) constr(v) :=
  let H := fresh in
  assert (x = v) as H by reflexivity;
  clear H.

Tactic Notation "Case_aux" ident(x) constr(name) :=
  first [
    set (x := name); move_to_top x
  | assert_eq x name; move_to_top x
  | fail 1 "because we are working on a different case" ].

Tactic Notation "Case" constr(name) := Case_aux Case name.
Tactic Notation "SCase" constr(name) := Case_aux SCase name.
Tactic Notation "SSCase" constr(name) := Case_aux SSCase name.
Tactic Notation "SSSCase" constr(name) := Case_aux SSSCase name.
Tactic Notation "SSSSCase" constr(name) := Case_aux SSSSCase name.
Tactic Notation "SSSSSCase" constr(name) := Case_aux SSSSSCase name.
Tactic Notation "SSSSSSCase" constr(name) := Case_aux SSSSSSCase name.
Tactic Notation "SSSSSSSCase" constr(name) := Case_aux SSSSSSSCase name.

Theorem andb_true_elim1 : ∀ b c : bool,
  andb b c = true → b = true.
Proof.
  intros b c H.
  destruct b.
  - (* b = fales *)
    reflexivity.
  - (* b = false *)
    rewrite <- H.
    simpl. reflexivity. Qed.

(* TODO : う， Case なんか使えない *)

Theorem andb_true_elim2 : ∀ b c : bool,
  andb b c = true → c = true.
Proof.
  intros.
  destruct c.
  - (* c = true *)
  reflexivity.
  - (* c = false *)
  rewrite <- H.
  destruct b.
  -- (* b = true *)
  simpl. reflexivity.
  -- (* b = false *)
  simpl. reflexivity.
Qed.



Theorem plus_0_r: ∀ n:nat,
  n + 0 = n.
Proof.
  intros n. induction n as [| n'].
  -
  simpl. reflexivity.
  -
  simpl. rewrite IHn'. reflexivity.
Qed.

Theorem minus_diag : ∀ n,
  minus n n = 0.
Proof.
  intros n. induction n as [| n'].
  -
    simpl. reflexivity.
  -
    simpl. rewrite -> IHn'. reflexivity. Qed.

(* 練習問題 xx -- *)
Theorem mult_0_r : ∀ n:nat,
  n * 0 = 0.
Proof.
  intros. induction n.
  -
  reflexivity.
  -
  Print Nat.mul.
  simpl. trivial.
Qed.

Theorem plus_n_Sm : ∀ n m : nat,
  S (n + m) = n + (S m).
Proof.
  intros.
  induction n.
  - auto.
  - auto.
Qed.

Theorem plus_comm : ∀ n m : nat,
  n + m = m + n.
Proof.
  intros.
  induction n.
  -
    auto.
  -
    simpl. rewrite IHn.
    induction m.
    --
      auto.
    --
      auto.
Qed.
(* -- *)


Fixpoint double (n:nat) :=
  match n with
  | O => O
  | S n' => S (S (double n'))
  end.

(* 練習問題 xx *)
Lemma double_plus : ∀ n, double n = n + n .
Proof.
  intros.
  induction n.
  -
    trivial.
  -
    simpl. rewrite IHn.
    Print plus_comm.
    specialize (plus_comm n (S n)).
    intro. rewrite H. simpl.
    reflexivity.
Qed.

(*
練習問題: ★ (destruct_induction)
destructとinductionの違いを短く説明しなさい。
*)

(*

場合分けと帰納法 ?

destruct x.
は， x : A だとしたら，
Inductive A :=
  | なんとか1 : A
  | なんとか2 : A.

みたいに定義されているものについて，どの定義の形をしているか，を分ける．


induction x.
は， x : A だとしたら，

Inductive A :=
  | O : A
  | S O : A -> A.

みたいに定義されているとしたら，
もとのゴールが forall x:A, P x.
だとしたら，
P 0 /\ (forall n:A, P n -> P (S n)) を導出して，もとのゴールを示す．


*)

(* CoqIDE おちてデータ少し飛んだ，いいや *)


Theorem plus_assoc : forall n m p : nat,
  (n + m) + p = n + (m + p).
Proof.
  intros.
  induction n.
  trivial.
  simpl.
  rewrite IHn.
  reflexivity.
Qed.


Theorem plus_swap' : ∀ n m p : nat,
  n + (m + p) = m + (n + p).
Proof.
  intros n m p.
  rewrite <- plus_assoc.
  rewrite <- plus_assoc.
  Admitted.


(*
練習問題: ★★★★★ (binary_inverse)
この練習問題は前の問題の続きで、2進数に関するものである。前の問題で作成された定義や定理をここで用いてもよい。

(a) まず自然数を2進数に変換する関数を書きなさい。そして「任意の自然数からスタートし、それを2進数にコンバートし、それをさらに自然数にコンバートすると、スタート時の自然数に戻ることを証明しなさい。

(b) あなたはきっと、逆方向についての証明をしたほうがいいのでは、と考えているでしょう。それは、任意の2進数から始まり、それを自然数にコンバートしてから、また2進数にコンバートし直したものが、元の自然数と一致する、という証明です。しかしながら、この結果はtrueにはなりません。！！その原因を説明しなさい。

(c) 2進数を引数として取り、それを一度自然数に変換した後、また2進数に変換したものを返すnormalize関数を作成し、証明しなさい。

*)

Inductive bin:Type :=
  | O : bin
  | D : bin -> bin
  | A : bin -> bin.


Definition incb a:bin := A a.

Fixpoint bin2nat (a:bin): nat :=
  match a with
  | O => 0
  | D x => 2 * bin2nat x
  | A x => 1 + bin2nat x
  end.

Definition inc (x:nat):nat := S x.

Lemma inc_trans_comm: forall b:bin,
  bin2nat (incb b) = inc (bin2nat b).
Proof.
  intros.
  induction b.
  -
    auto.
  -
    simpl. unfold inc. reflexivity.
  -
    simpl. auto.
Qed.

(*

練習問題: ★★, optional (decreasing)
各関数の引数のいくつかが"減少的"でなければならない、という要求仕様は、Coqのデザインにおいて基礎となっているものです。特に、そのことによって、Coq上で作成された関数が、どんな入力を与えられても必ずいつか終了する、ということが保障されています。しかし、Coqの"減少的な解析"が「とても洗練されているとまではいえない」ため、時には不自然な書き方で関数を定義しなければならない、ということもあります。

これを具体的に感じるため、Fixpointで定義された、より「微妙な」関数の書き方を考えてみましょう（自然数に関する簡単な関数でかまいません）。それが全ての入力で停止することと、Coqがそれを、この制限のため受け入れてくれないことを確認しなさい。

*)

(*
Fixpoint f (a:nat): nat :=
  match a with
  | 0 => 0
  | 1 => 1
  | 13 => f 100
  | S (S x) => 5 + f x
  end.
*)
































































