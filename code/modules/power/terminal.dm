// the underfloor wiring terminal for the APC
// autogenerated when an APC is placed
// all conduit connects go to this object instead of the APC
// using this solves the problem of having the APC in a wall yet also inside an area

/obj/machinery/power/terminal
	name = "terminal"
	icon_state = "term"
	desc = "It's an underfloor wiring terminal for power equipment."
	level = 1
	var/obj/machinery/power/master = null
	anchored = 1
	layer = WIRE_TERMINAL_LAYER //a bit above wires
	var/priority = FALSE //mapping var
	power_group = POWER_GROUP_SMES_INPUT

/obj/machinery/power/terminal/New()
	..()
	var/turf/T = src.loc
	if(level==1) hide(T.intact)
	return

/obj/machinery/power/terminal/Destroy()
	if(master)
		master.disconnect_terminal()
	return ..()

/obj/machinery/power/terminal/hide(i)
	if(i)
		invisibility = INVISIBILITY_MAXIMUM
		icon_state = "term-f"
	else
		invisibility = 0
		icon_state = "term"


/obj/machinery/power/proc/can_terminal_dismantle()
	. = 0

/obj/machinery/power/apc/can_terminal_dismantle()
	. = 0
	if(opened)
		. = 1

/obj/machinery/power/smes/can_terminal_dismantle()
	. = 0
	if(panel_open)
		. = 1


/obj/machinery/power/terminal/proc/dismantle(mob/living/user, obj/item/W)
	if(isturf(loc))
		var/turf/T = loc
		if(T.intact)
			to_chat(user, "<span class='warning'>You must first expose the power terminal!</span>")
			return

		if(!master || master.can_terminal_dismantle())
			user.visible_message("[user.name] dismantles the power terminal from [master].", \
								"<span class='notice'>You begin to cut the cables...</span>")

			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			if(do_after(user, 50*W.toolspeed, target = src))
				if(!master || master.can_terminal_dismantle())
					if(prob(50) && electrocute_mob(user, powernet, src, 1, TRUE))
						do_sparks(5, TRUE, master)
						return
					new /obj/item/stack/cable_coil(loc, 10)
					to_chat(user, "<span class='notice'>You cut the cables and dismantle the power terminal.</span>")
					qdel(src)


/obj/machinery/power/terminal/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/weapon/wirecutters))
		dismantle(user, W)
	else
		return ..()
