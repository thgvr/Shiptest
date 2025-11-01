//Joywire
/obj/item/organ/cyberimp/brain/midised/joywire
	name = "\improper Midi-Sed pleasure vivifier"
	desc = "A widely popular (and addictive) implant produced by Miditeke-Sedari Tokoce that stimulates the brain's pleasure centers. Dramatically increases mood, but interferes with taste reception even if uninstalled."
	implant_color = "#FFABE0"
	slot = ORGAN_SLOT_BRAIN_JOYWIRE
	implant_manufacturer = CYBERWARE_MIDISED

/obj/item/organ/cyberimp/brain/joywire/on_life()
	if(owner || !(organ_flags & ORGAN_FAILING))
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "joywire", /datum/mood_event/joywire)
		ADD_TRAIT(owner, TRAIT_AGEUSIA, TRAIT_GENERIC)

/obj/item/organ/cyberimp/brain/joywire/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	organ_flags |= ORGAN_FAILING
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "joywire")
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "joywire_emp", /datum/mood_event/joywire_emp)
	to_chat(owner, span_boldwarning("That feeling of dream-like, distilled joy is suddenly diluted. Misery sets in..."))

//Agonywire
/obj/item/organ/cyberimp/brain/midised/mindscrew
	name = "\improper Midi-Sed MNDFCK implant"
	desc = "A horrific after-market modification of Midi-Sed's pleasure vivifier that stimulates intense pain in the brain. Dramatically hurts a user's mood and mental state, and lingers for a time after removal."
	implant_color = "#5E1108"
	slot = ORGAN_SLOT_BRAIN_JOYWIRE
	implant_manufacturer = CYBERWARE_MIDISED

/obj/item/organ/cyberimp/brain/mindscrew/on_life()
	if(owner || !(organ_flags & ORGAN_FAILING))
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "mindscrew", /datum/mood_event/mindscrew)
