/* User Process — Smart Health & Wellness Center */
/* Each user selects a service non-deterministically,
   requests booking, handles payment, then accesses service */

active [MAX_USERS] proctype User() {
    byte user_id = _pid;
    byte service_id;
    mtype msg;
    byte result;

    /* Service selection - non-deterministic choice */
    if
    :: service_id = 1
    :: service_id = 2
    :: service_id = 3
    fi;

    /* Booking Flow */
    user_to_system!REQUEST_BOOKING, user_id, service_id;
    system_to_user?msg, user_id, result;

    if
    :: (msg == CONFIRM_AVAILABLE) ->
        user_to_system!PAYMENT_PENDING, user_id, service_id;
        system_to_user?msg, user_id, result;

        if
        :: (msg == PAY_SUCCESS) ->
            user_bookings[user_id] = service_id;
            printf("User %d: Booking confirmed for service %d\n", user_id, service_id);
        :: (msg == PAY_FAIL) ->
            printf("User %d: Payment failed for service %d\n", user_id, service_id);
        fi;
    :: (msg == SERVICE_UNAVAILABLE) ->
        printf("User %d: Service %d unavailable\n", user_id, service_id);
    fi;

    /* Service Access */
    if
    :: (user_bookings[user_id] != 0) ->
        user_to_system!SERVICE_ACCESS, user_id, user_bookings[user_id];
        printf("User %d: Accessed service %d\n", user_id, user_bookings[user_id]);
    fi;
}
