/* Booking System Process */
/* Handles: booking requests, payment initiation, service access control */

active proctype BookingSystem() {
    mtype msg;
    byte user_id, service_id;
    int amount;
    byte result = 0;

    do
    :: user_to_system?msg, user_id, service_id ->
        if
        /* Booking Request */
        :: (msg == REQUEST_BOOKING) ->
            if
            :: (service_id >= 1 && service_id <= MAX_SERVICES && staff_available[service_id-1]) ->
                system_to_user!CONFIRM_AVAILABLE, user_id, result;
                staff_available[service_id-1] = false;
                printf("System: Service %d booked for user %d\n", service_id, user_id);
            :: else ->
                system_to_user!SERVICE_UNAVAILABLE, user_id, result;
                printf("System: Service %d unavailable for user %d\n", service_id, user_id);
            fi;
        /* Payment Initiation */
        :: (msg == PAYMENT_PENDING) ->
            amount = 50;
            system_to_payment!PAYMENT_PENDING, user_id, amount;
            printf("System: Payment request for user %d, amount $%d\n", user_id, amount);
        /* Service Access */
        :: (msg == SERVICE_ACCESS) ->
            if
            :: (payment_status[user_id] == 1) ->
                printf("System: User %d accessed service %d\n", user_id, service_id);
            :: else ->
                printf("System: Access DENIED for user %d (unpaid)\n", user_id);
            fi;
        fi;
    od;
}
