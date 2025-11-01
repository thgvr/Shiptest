/obj/item/organ/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "Injectors of extra sub-routines for the brain."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"

	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

	bad_type = /obj/item/organ/cyberimp/brain

/obj/item/organ/cyberimp/brain/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/stun_amount = 200/severity
	owner.Stun(stun_amount)
	to_chat(owner, span_warning("Your body seizes up!"))

/obj/item/organ/cyberimp/brain/datachip
	name = "nanotrasen brain datachip"
	desc = "Covered in serial codes and warnings. That data must be important."
