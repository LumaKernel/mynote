Section Hi.

Goal exists n : nat, n = n.
eexists ?[x].
reflexivity.
[x]: exact 0.
Qed.

(* (* "*)" *) *)

(* Axiom X:True.A. *)
Ltac name_goal name := refine ?[name].
Theorem A: forall n, n + 0 = n.
induction n ; [refine ?[お''] | refine ?[step]].
(**)[(**)お''(* *)](*" *) ""*)" *):
	(**){(**)simpl. admit. (* (* " *) """ *) *)}(**)
	[step] : {
		admit.
	}
Admitted.

End Hi.