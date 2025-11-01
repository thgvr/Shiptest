//Implant
/obj/item/organ/cyberimp/arm/retractable/escutcheon
	name = "Escutcheon shield implant"
	desc = "Sturdy, fanned shield that hides within implanted machinery in the forearm."
	contents = newlist(/obj/item/melee/sword/tarsus_blade)
	implant_manufacturer = CYBERWARE_ATUA

/obj/item/organ/cyberimp/arm/retractable/escutcheon/l
	zone = BODY_ZONE_L_ARM

//Item it uses
#warn needs a sprite
/obj/item/shield/riot/escutcheon
	name = "escutcheon shield"
	desc = "Sturdy, fanned shield that hides within implanted machinery in the forearm. Surprisingly durable."
	hitsound = 'sound/weapons/bladeslice.ogg'

	flags_1 = CONDUCT_1
	force = 15
	block_chance = 45
	max_integrity = 1500
