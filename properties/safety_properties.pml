/* Safety Properties — System Invariants */

/* Valid booking values (0-3 only) */
ltl safety_valid_bookings {
    [](user_bookings[0] >= 0 && user_bookings[0] <= 3) &&
    [](user_bookings[1] >= 0 && user_bookings[1] <= 3) &&
    [](user_bookings[2] >= 0 && user_bookings[2] <= 3)
}

/* Valid payment status (0 or 1 only) */
ltl safety_valid_payment_status {
    [](payment_status[0] >= 0 && payment_status[0] <= 1) &&
    [](payment_status[1] >= 0 && payment_status[1] <= 1) &&
    [](payment_status[2] >= 0 && payment_status[2] <= 1)
}

/* No channel overflow */
ltl no_channel_overflow {
    [](len(user_to_system) <= 5 && len(system_to_user) <= 5)
}

/* No user can have multiple concurrent services */
ltl no_multiple_services {
    [](!(user_bookings[0] == 1 && user_bookings[0] == 2)) &&
    [](!(user_bookings[0] == 1 && user_bookings[0] == 3)) &&
    [](!(user_bookings[0] == 2 && user_bookings[0] == 3))
}

/* Initial state properties */
ltl initial_payment_status {
    (payment_status[0] == 0) && (payment_status[1] == 0) && (payment_status[2] == 0)
}

ltl initial_bookings_empty {
    (user_bookings[0] == 0) && (user_bookings[1] == 0) && (user_bookings[2] == 0)
}

ltl initial_staff_available {
    (staff_available[0] == true) && (staff_available[1] == true) && (staff_available[2] == true)
}
