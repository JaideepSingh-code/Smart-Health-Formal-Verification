/* LTL Properties — Scheduling & Booking (FR6–FR12) */

/* FR12: No double-booking of services */
ltl exclusive_booking {
    [](!((user_bookings[0] == 1) && (user_bookings[1] == 1)) &&
       !((user_bookings[0] == 1) && (user_bookings[2] == 1)) &&
       !((user_bookings[1] == 1) && (user_bookings[2] == 1)))
}

/* FR6: Users can only book available services */
ltl book_only_available {
    [](user_bookings[0] == 1 -> staff_available[0] == false) &&
    [](user_bookings[1] == 1 -> staff_available[0] == false) &&
    [](user_bookings[2] == 1 -> staff_available[0] == false)
}

/* FR6: Available services have no bookings */
ltl available_means_unbooked {
    [](staff_available[0] == true ->
        (user_bookings[0] != 1 && user_bookings[1] != 1 && user_bookings[2] != 1))
}

/* FR7: Valid user booking management */
ltl valid_user_booking {
    [](user_bookings[0] != 0 -> user_bookings[0] >= 1 && user_bookings[0] <= 3) &&
    [](user_bookings[1] != 0 -> user_bookings[1] >= 1 && user_bookings[1] <= 3) &&
    [](user_bookings[2] != 0 -> user_bookings[2] >= 1 && user_bookings[2] <= 3)
}

/* FR7: Booking requests eventually processed */
ltl booking_eventually_processed {
    [](len(user_to_system) > 0 -> <>(len(user_to_system) == 0))
}

/* FR8: System responds to booking requests */
ltl system_responds {
    []<>(len(user_to_system) == 0 && len(system_to_user) == 0)
}

/* FR8: Booking system makes progress */
ltl booking_progress {
    [](len(user_to_system) > 0 -> <>(len(user_to_system) < 5))
}

/* FR11: User bookings are tracked properly */
ltl booking_tracking {
    [](user_bookings[0] != 0 -> user_bookings[0] != 255) &&
    [](user_bookings[1] != 0 -> user_bookings[1] != 255) &&
    [](user_bookings[2] != 0 -> user_bookings[2] != 255)
}
