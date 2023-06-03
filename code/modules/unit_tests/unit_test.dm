/*

Usage:
Override /Run() to run your test code

Call Fail() to fail the test (You should specify a reason)

You may use /New() and /Destroy() for setup/teardown respectively

You can use the run_loc_floor_bottom_left and run_loc_floor_top_right to get turfs for testing

*/

GLOBAL_DATUM(current_test, /datum/unit_test)
GLOBAL_VAR_INIT(failed_any_test, FALSE)
GLOBAL_VAR(test_log)

/datum/unit_test
	//Bit of metadata for the future maybe
	var/list/procs_tested

	/// The bottom left floor turf of the testing zone
	var/turf/run_loc_floor_bottom_left

	/// The top right floor turf of the testing zone
	var/turf/run_loc_floor_top_right

	///The priority of the test, the larger it is the later it fires
	var/priority = TEST_DEFAULT

	/// The type of turf to allocate for the testing zone
	var/test_turf_type = /turf/open/floor/plasteel

	//internal shit
	var/focus = FALSE
	var/succeeded = TRUE
	var/list/allocated
	var/list/fail_reasons

	var/static/datum/space_level/reservation

	//var/static/datum/map_zone/mapzone

/proc/cmp_unit_test_priority(datum/unit_test/a, datum/unit_test/b)
	return initial(a.priority) - initial(b.priority)

/datum/unit_test/New()
	if (isnull(reservation))
		var/datum/map_template/unit_tests/template = new
		reservation = template.load_new_z()
/*
	if (isnull(mapzone))
		var/height = 7
		var/width = 7
		mapzone = SSmapping.create_map_zone("Integration Test Mapzone")
		var/datum/virtual_level/vlevel = SSmapping.create_virtual_level("Integration Test Virtual Level", ZTRAITS_STATION, mapzone, width, height, ALLOCATION_FREE)
		vlevel.reserve_margin(2)
		vlevel.fill_in(/turf/open/floor/plasteel, /area/testroom)
*/
	allocated = new
/*
	var/datum/virtual_level/vlevel = mapzone.virtual_levels[1]
	run_loc_bottom_left = vlevel.get_unreserved_bottom_left_turf()					//i dont know how this works !
	run_loc_top_right = vlevel.get_unreserved_top_right_turf()
*/
	run_loc_floor_bottom_left = get_turf(locate(/obj/effect/landmark/unit_test_bottom_left) in GLOB.landmarks_list)
	run_loc_floor_top_right = get_turf(locate(/obj/effect/landmark/unit_test_top_right) in GLOB.landmarks_list)

	TEST_ASSERT(isfloorturf(run_loc_floor_bottom_left), "run_loc_floor_bottom_left was not a floor ([run_loc_floor_bottom_left])")
	TEST_ASSERT(isfloorturf(run_loc_floor_top_right), "run_loc_floor_top_right was not a floor ([run_loc_floor_top_right])")

/datum/unit_test/Destroy()
	QDEL_LIST(allocated)
	// clear the test area
	for(var/turf/turf in block(locate(1, 1, run_loc_floor_bottom_left.z), locate(world.maxx, world.maxy, run_loc_floor_bottom_left.z)))
		for (var/content in turf.contents)
			if (iseffect(content))
				continue
			qdel(content)
	return ..()

/datum/unit_test/proc/Run()
	Fail("Run() called parent or not implemented")

/datum/unit_test/proc/Fail(reason = "No reason")
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYADD(fail_reasons, reason)

/// Allocates an instance of the provided type, and places it somewhere in an available loc
/// Instances allocated through this proc will be destroyed when the test is over
/datum/unit_test/proc/allocate(type, ...)
	var/list/arguments = args.Copy(2)
	if (!arguments.len)
		arguments = list(run_loc_floor_bottom_left)
	else if (arguments[1] == null)
		arguments[1] = run_loc_floor_bottom_left
	var/instance = new type(arglist(arguments))
	allocated += instance
	return instance

/proc/RunUnitTest(test_path, list/test_results)
	var/datum/unit_test/test = new test_path

	GLOB.current_test = test
	var/duration = REALTIMEOFDAY

	test.Run()

	duration = REALTIMEOFDAY - duration
	GLOB.current_test = null
	GLOB.failed_any_test |= !test.succeeded

	var/list/log_entry = list("[test.succeeded ? "PASS" : "FAIL"]: [test_path] [duration / 10]s")
	var/list/fail_reasons = test.fail_reasons

	for(var/J in 1 to LAZYLEN(fail_reasons))
		log_entry += "\tREASON #[J]: [fail_reasons[J]]"
	var/message = log_entry.Join("\n")
	log_test(message)

	test_results[test_path] = list("status" = test.succeeded ? UNIT_TEST_PASSED : UNIT_TEST_FAILED, "message" = message, "name" = test_path)

	qdel(test)

	SSticker.force_ending = TRUE
	//Comment from tgstation: We have to call this manually because del_text can preceed us, and SSticker doesn't fire in the post game
	//We don't actually need to call standard_reboot, but leaving it under a condition in case it becomes necessary in the future.
	//To my understanding, something triggers a reboot when it's created/deleted, which could interrupt the tests and restart the server.
	//To prevent this, create_and_destroy prevents the reboot from happening. However, this also prevents the reboot from ever happening naturally.
	//Because of this, in case something does actually attempt to reboot prematurely, we need to manually initiate the reboot.
	if(SSticker.ready_for_reboot)
		SSticker.standard_reboot()

/datum/map_template/unit_tests
	name = "Unit Tests Zone"
	mappath = "_maps/templates/unit_tests.dmm"
