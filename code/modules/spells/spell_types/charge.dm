/obj/effect/proc_holder/spell/targeted/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."

	school = "transmutation"
	charge_max = 600
	clothes_req = FALSE
	invocation = "DIRI CEL"
	invocation_type = INVOCATION_WHISPER
	range = -1
	cooldown_min = 400 //50 deciseconds reduction per rank
	include_user = TRUE
	action_icon_state = "charge"

/obj/effect/proc_holder/spell/targeted/charge/cast(list/targets,mob/user = usr)
	for(var/mob/living/L in targets)
		var/list/hand_items = list(L.get_active_held_item(),L.get_inactive_held_item())
		var/charged_item = null
		var/burnt_out = FALSE

		if(L.pulling && isliving(L.pulling))
			var/mob/living/M =	L.pulling
			if(M.mob_spell_list.len != 0 || (M.mind && M.mind.spell_list.len != 0))
				for(var/obj/effect/proc_holder/spell/S in M.mob_spell_list)
					S.charge_counter = S.charge_max
				if(M.mind)
					for(var/obj/effect/proc_holder/spell/S in M.mind.spell_list)
						S.charge_counter = S.charge_max
				to_chat(M, span_notice("You feel raw magic flowing through you. It feels good!"))
			else
				to_chat(M, span_notice("You feel very strange for a moment, but then it passes."))
				burnt_out = TRUE
			charged_item = M
			break
		for(var/obj/item in hand_items)
			if(istype(item, /obj/item/spellbook))
				to_chat(L, span_danger("Glowing red letters appear on the front cover..."))
				to_chat(L, span_warning("[pick("NICE TRY BUT NO!","CLEVER BUT NOT CLEVER ENOUGH!", "SUCH FLAGRANT CHEESING IS WHY WE ACCEPTED YOUR APPLICATION!", "CUTE! VERY CUTE!", "YOU DIDN'T THINK IT'D BE THAT EASY, DID YOU?")]"))
				burnt_out = TRUE
			else if(istype(item, /obj/item/book/granter/spell))
				var/obj/item/book/granter/spell/I = item
				if(!I.oneuse)
					to_chat(L, span_notice("This book is infinite use and can't be recharged, yet the magic has improved the book somehow..."))
					burnt_out = TRUE
					I.pages_to_mastery--
					break
				if(prob(80))
					L.visible_message(span_warning("[I] catches fire!"))
					qdel(I)
				else
					I.used = FALSE
					charged_item = I
					break
			else if(istype(item, /obj/item/stock_parts/cell))
				var/obj/item/stock_parts/cell/C = item
				if(!C.self_recharge)
					if(prob(80))
						C.maxcharge -= 200
					if(C.maxcharge <= 1) //Div by 0 protection
						C.maxcharge = 1
						burnt_out = TRUE
				C.charge = C.maxcharge
				charged_item = C
				break
			else if(item.contents)
				var/obj/I = null
				for(I in item.contents)
					if(istype(I, /obj/item/stock_parts/cell/))
						var/obj/item/stock_parts/cell/C = I
						if(!C.self_recharge)
							if(prob(80))
								C.maxcharge -= 200
							if(C.maxcharge <= 1) //Div by 0 protection
								C.maxcharge = 1
								burnt_out = TRUE
						C.charge = C.maxcharge
						if(istype(C.loc, /obj/item/gun))
							var/obj/item/gun/G = C.loc
							G.process_chamber()
						item.update_appearance()
						charged_item = item
						break
		if(!charged_item)
			to_chat(L, span_notice("You feel magical power surging through your hands, but the feeling rapidly fades..."))
		else if(burnt_out)
			to_chat(L, span_warning("[charged_item] doesn't seem to be reacting to the spell!"))
		else
			playsound(get_turf(L), 'sound/magic/charge.ogg', 50, TRUE)
			to_chat(L, span_notice("[charged_item] suddenly feels very warm!"))
