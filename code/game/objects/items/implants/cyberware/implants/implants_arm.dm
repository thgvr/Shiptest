/obj/item/organ/cyberimp/arm
	name = "arm-mounted implant"
	zone = BODY_ZONE_R_ARM
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_SMALL

	bad_type = /obj/item/organ/cyberimp/arm

/obj/item/organ/cyberimp/arm/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_ARM)
			slot = ORGAN_SLOT_LEFT_ARM_AUG
		if(BODY_ZONE_R_ARM)
			slot = ORGAN_SLOT_RIGHT_ARM_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/arm/update_icon()
	. = ..()
	if(zone == BODY_ZONE_R_ARM)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/arm/examine(mob/user)
	. = ..()
	. += span_info("It's in [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm mode. Use a <b>screwdriver</b> to swap it.")

/obj/item/organ/cyberimp/arm/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(.)
		return TRUE

	tool.play_tool_sound(src)
	if(zone == BODY_ZONE_R_ARM)
		zone = BODY_ZONE_L_ARM
	else
		zone = BODY_ZONE_R_ARM
	SetSlotFromZone()
	to_chat(user, span_notice("You modify [src] to be installed on the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."))
	update_appearance()

/obj/item/organ/cyberimp/arm/retractable
	actions_types = list(/datum/action/item_action/organ_action/toggle)

	///A ref for the arm we're taking up. Mostly for the unregister signal upon removal
	var/obj/hand
	///A list of typepaths to create and insert into ourself on init
	var/list/items_to_create = list()
	/// Used to store a list of all items inside, for multi-item implants.
	var/list/items_list = list()// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.
	/// You can use this var for item path, it would be converted into an item on New().
	var/obj/item/active_item
	/// Sound played when extending
	var/extend_sound = 'sound/mecha/mechmove03.ogg'
	/// Sound played when retracting
	var/retract_sound = 'sound/mecha/mechmove03.ogg'

/obj/item/organ/cyberimp/arm/retractable/Initialize()
	. = ..()
	if(ispath(active_item))
		active_item = new active_item(src)
		items_list += WEAKREF(active_item)

	for(var/typepath in items_to_create)
		var/atom/new_item = new typepath(src)
		items_list += WEAKREF(new_item)

	update_appearance()
	SetSlotFromZone()

/obj/item/organ/cyberimp/arm/retractable/Destroy()
	hand = null
	active_item = null
	for(var/datum/weakref/ref in items_list)
		var/obj/item/to_del = ref.resolve()
		if(!to_del)
			continue
		qdel(to_del)
	items_list.Cut()
	return ..()

/obj/item/organ/cyberimp/arm/retractable/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	var/side = zone == BODY_ZONE_R_ARM? RIGHT_HANDS : LEFT_HANDS
	hand = owner.hand_bodyparts[side]
	if(hand)
		RegisterSignal(hand, COMSIG_ITEM_ATTACK_SELF, PROC_REF(ui_action_click)) //If the limb gets an attack-self, open the menu. Only happens when hand is empty
		RegisterSignal(M, COMSIG_KB_MOB_DROPITEM_DOWN, PROC_REF(dropkey)) //We're nodrop, but we'll watch for the drop hotkey anyway and then stow if possible.

/obj/item/organ/cyberimp/arm/retractable/Remove(mob/living/carbon/M, special = 0)
	Retract()
	if(hand)
		UnregisterSignal(hand, COMSIG_ITEM_ATTACK_SELF)
		UnregisterSignal(M, COMSIG_KB_MOB_DROPITEM_DOWN)
	..()

/**
 * Called when the mob uses the "drop item" hotkey
 *
 * Items inside toolset implants have TRAIT_NODROP, but we can still use the drop item hotkey as a
 * quick way to store implant items. In this case, we check to make sure the user has the correct arm
 * selected, and that the item is actually owned by us, and then we'll hand off the rest to Retract()
**/
/obj/item/organ/cyberimp/arm/retractable/proc/dropkey(mob/living/carbon/host)
	if(!host)
		return //How did we even get here
	if(hand != host.hand_bodyparts[host.active_hand_index])
		return //wrong hand
	Retract()

/obj/item/organ/cyberimp/arm/retractable/proc/Retract()
	if(!active_item || (active_item in src))
		return

	owner.visible_message(
		span_notice("[owner] retracts [active_item] back into [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_notice("[active_item] snaps back into your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_hear("You hear a short mechanical noise."),
	)

	owner.transferItemToLoc(active_item, src, TRUE)
	playsound(get_turf(owner), retract_sound, 35, TRUE)
	active_item = null

/obj/item/organ/cyberimp/arm/retractable/proc/Extend(obj/item/item)
	if(!(item in src))
		return

	active_item = item

	ADD_TRAIT(active_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	active_item.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	active_item.slot_flags = null
	active_item.set_custom_materials(null)

	var/side = zone == BODY_ZONE_R_ARM? RIGHT_HANDS : LEFT_HANDS
	var/hand = owner.get_empty_held_index_for_side(side)
	if(hand)
		owner.put_in_hand(active_item, hand)

	else
		var/list/hand_items = owner.get_held_items_for_side(side, all = TRUE)
		var/success = FALSE
		var/list/failure_message = list()
		for(var/i in 1 to hand_items.len) //Can't just use *in* here.
			var/I = hand_items[i]
			if(!owner.dropItemToGround(I))
				failure_message += span_warning("Your [I] interferes with [src]!")
				continue
			to_chat(owner, span_notice("You drop [I] to activate [src]!"))
			success = owner.put_in_hand(active_item, owner.get_empty_held_index_for_side(side))
			break

		if(!success)
			for(var/i in failure_message)
				to_chat(owner, i)
			return

	owner.visible_message(
		span_notice("[owner] extends [active_item] from [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_notice("You extend [active_item] from your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_hear("You hear a short mechanical noise."),
	)
	playsound(get_turf(owner), extend_sound, 50, TRUE)

/obj/item/organ/cyberimp/arm/retractable/ui_action_click()
	if((organ_flags & ORGAN_FAILING) || (!active_item && !contents.len))
		to_chat(owner, span_warning("The implant doesn't respond."))
		return

	if(!active_item || (active_item in src))
		active_item = null
		if(contents.len == 1)
			Extend(contents[1])
		else
			var/list/choice_list = list()
			for(var/datum/weakref/augment_ref in items_list)
				var/obj/item/augment_item = augment_ref.resolve()
				if(!augment_item)
					items_list -= augment_ref
					continue
				choice_list[augment_item] = image(augment_item)
			var/obj/item/choice = show_radial_menu(owner, owner, choice_list)
			if(owner && owner == usr && owner.stat != DEAD && (src in owner.internal_organs) && !active_item && (choice in contents))
				// This monster sanity check is a nice example of how bad input is. //yeah
				Extend(choice)
	else
		Retract()

/obj/item/organ/cyberimp/arm/retractable/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, "<span class='warning'>The electromagnetic pulse causes [src] to malfunction!</span>")
		// give the owner an idea about why his implant is glitching
		Retract()

//IPC charger
/obj/item/organ/cyberimp/arm/power_cord
	name = "power cord implant"
	desc = "An internal power cord hooked up to a battery. Useful if you run on volts."
	contents = newlist(/obj/item/apc_powercord)
	zone = BODY_ZONE_L_ARM
