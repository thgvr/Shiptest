//Implant
/obj/item/organ/cyberimp/arm/retractable/tarsus
	name = "Tarsus blade implant"
	desc = "Long, sleek blades sure to instill fear into anything that bleeds. Installed along the forearm."
	contents = newlist(/obj/item/melee/sword/tarsus_blade)
	implant_manufacturer = CYBERWARE_ATUA

/obj/item/organ/cyberimp/arm/retractable/tarsus/l
	zone = BODY_ZONE_L_ARM

//Item it uses
/obj/item/melee/sword/tarsus_blade
	name = "tarsus blade"
	desc = "Long, sleek blades sure to instill fear into anything that bleeds."
	icon_state = "mantis"
	item_state = "mantis"
	icon = 'icons/obj/weapon/sword.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'

	flags_1 = CONDUCT_1
	force = 25
	wound_bonus = 20
	attack_verb = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "cut")
	max_integrity = 200

/obj/item/melee/sword/tarsus_blade/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS)
		return

	var/side = user.get_held_index_of_item(src)
	if(side == LEFT_HANDS)
		transform = null
	else
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/melee/sword/tarsus_blade/attack(mob/living/M, mob/living/user)
	. = ..()
	if(user.get_active_held_item() != src)
		return

	var/obj/item/some_item = user.get_inactive_held_item()
	if(!istype(some_item,type))
		return

	user.do_attack_animation(M,null,some_item)
	some_item.attack(M,user)

/obj/item/melee/sword/tarsus_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag || get_dist(user,target) > 3 || !isliving(target))
		return

	for(var/i in 1 to get_dist(user,target))
		step_towards(user,target)
	attack(target,user)
