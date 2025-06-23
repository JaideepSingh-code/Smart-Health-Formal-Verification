/* LTL Properties — Payment & Billing System */

/* Payment must be successful before service access */
ltl payment_before_access {
    [](((user_bookings[0] != 0) && (len(user_to_system) == 0)) -> (payment_status[0] == 1))
}

/* Payment status consistency */
ltl payment_status_consistency {
    []((payment_status[0] == 1) -> X(payment_status[0] == 1))
}

/* Service booking makes staff unavailable */
ltl booking_makes_unavailable {
    []((user_bookings[0] == 1) -> (staff_available[0] == false))
}

/* User cannot have booking without payment */
ltl booking_requires_payment {
    []((user_bookings[0] != 0) -> (payment_status[0] == 1))
}

/* Payment stability — once paid, stays paid */
ltl payment_stability {
    []((payment_status[0] == 1) -> [](payment_status[0] == 1))
}

/* Service exclusivity — at most one user per service */
ltl service_exclusivity {
    [](!((user_bookings[0] == user_bookings[1]) && (user_bookings[0] != 0)))
}
