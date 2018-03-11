//Console, radiation + humans = bad
/obj/machinery/computer/fusion_reactor_control
	name = "fusion reactor control console"
	desc = "The controller for the shiny and expensive reactor."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list( )
	var/obj/machinery/fusion_reactor/linked




#define RADIATION_AMOUNT 300

//Fusion Reactor
/obj/machinery/fusion_reactor
	name = "Fusion Reactor"
	desc = "A very expensive device, very shiny."
	icon = 'icons/obj/machines/fusion_reactor.dmi'
	anchored = TRUE
	density = TRUE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/sprite_number = 0
	var/on = TRUE


/obj/machinery/fusion_reactor/main

	icon_state = "reactor_0_anim"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/list/parts = list()
	var/breaker = 1
	var/obj/middle = null


/obj/machinery/fusion_reactor/main/Initialize()
	. = ..()
	setup_parts()
	middle.add_overlay("plasma_chamber_on")
	connect()

/obj/machinery/fusion_reactor/main/proc/setup_parts()
	var/turf/main_turf = get_turf(src)

	var/list/spawn_turfs = block(locate(main_turf.x - 1, main_turf.y + 2, main_turf.z), locate(main_turf.x + 1, main_turf.y, main_turf.z))

	var/count = 10
	for(var/turf/T in spawn_turfs)
		count--
		if(T == main_turf) // Skip our turf.
			continue
		var/obj/machinery/fusion_reactor/part/part = new(T)
		if(count == 5) // Middle
			middle = part
		//if(count <= 3) // Their sprite is the top part of the generator
		//	part.density = FALSE
		//	part.layer = WALL_OBJ_LAYER
		part.sprite_number = count
		part.main_part = src
		parts += part
		part.update_icon()

/obj/machinery/fusion_reactor/main/process()
	if(on)
		//Radiation. Probability to reduce radiation message spam
		if(prob(30))
			pulse_rads()

/obj/machinery/fusion_reactor/main/proc/pulse_rads()
	//Configure radiation amount at top of file
	radiation_pulse(src, RADIATION_AMOUNT)

//Computer-Reactor Connection
/obj/machinery/fusion_reactor/main/proc/connect()
	//Presumes only 1 controller, which should be correct since no components for second exist
	var/obj/machinery/computer/fusion_reactor_control/C = locate()
	C.linked = src

// UI
/obj/machinery/fusion_reactor/main/interact(mob/user)
	var/content = "Fusion Reactor: "

	var/datum/browser/popup = new(user, "fusion_reactor", name)
	popup.set_content(content)
	popup.open()


//Console UI
/obj/machinery/computer/fusion_reactor_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  	if(!ui)
    	ui = new(user, src, ui_key, "fusion_reactor_control", name, 300, 300, master_ui, state)
    	ui.open()

/obj/machinery/computer/fusion_reactor_control/ui_data(mob/user)
	var/list/data = list()
	data["connected"] = (linked ? "Yes" : "No(Contact Admin)")


//Parts

/obj/machinery/fusion_reactor/part
	var/obj/machinery/fusion_reactor/main/main_part = null

/obj/machinery/fusion_reactor/part/attackby(obj/item/I, mob/user, params)
	return main_part.attackby(I, user)


/obj/machinery/fusion_reactor/part/attack_hand(mob/user)
	return main_part.attack_hand(user)

///obj/machinery/fusion_reactor/part/set_broken()
//	..()
//	if(main_part && !(main_part.stat & BROKEN))
		//main_part.set_broken()


/obj/machinery/fusion_reactor/update_icon()
	..()
	icon_state = "[get_status()]_[sprite_number]"



/obj/machinery/fusion_reactor/proc/get_status()
	return "off"