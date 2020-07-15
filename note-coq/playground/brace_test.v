
Variable A B : Type.
Variable f : A -> B.
Notation " (* a " := (f a) (at level 50).

Goal B.
     refine( ( * _ ) .
  Admitted.

Print Unnamed_thm.