/obj/item/organ/cyberimp
	name = "cybernetic implant"
	icon = 'icons/obj/implants/implant.dmi'
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

	var/implant_color = "#FFFFFF"
	var/implant_overlay
	///The manufacturer of the implant
	var/implant_manufacturer = CYBERWARE_DEFAULT

	bad_type = /obj/item/organ/cyberimp

/obj/item/organ/cyberimp/New(mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()

/obj/item/organ/cyberimp/examine(mob/user)
	. = ..()
	if(implant_manufacturer)
		. += span_notice("It has <b>[CYBERWARE_DEFAULT]</b> branding.")
