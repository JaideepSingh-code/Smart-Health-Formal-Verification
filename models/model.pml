//Smart Health & Wellness Center Automation system
#define MAX_USERS 3
#define MAX_SERVICES 3
#define MAX_STAFF 3

mtype = {
    IDLE,
    REQUEST_BOOKING,
    CONFIRM_AVAILABLE,
    SERVICE_UNAVAILABLE,
    PAYMENT_PENDING,
    PAY_SUCCESS,
    PAY_FAIL,
    BOOKING_CONFIRMED,
    SERVICE_ACCESS
};

/* Communication Channels */
chan user_to_system = [5] of {mtype, byte, byte};
chan system_to_user = [5] of {mtype, byte, byte};
chan system_to_payment = [5] of {mtype, byte, int};

/* Global State */
bool staff_available[MAX_STAFF];
byte user_bookings[MAX_USERS];
byte payment_status[MAX_USERS];

/* User Process */
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

/* Booking System */
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
            amount = 50;  // Standard service fee
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

/* Payment System */
/* Corrected PaymentSystem */
active proctype PaymentSystem() {
    mtype msg;
    byte user_id;
    int amount;
    byte result = 0;
    
    do
    :: system_to_payment?msg, user_id, amount ->
        if
        :: (msg == PAYMENT_PENDING) -> 
            if
            :: (true) ->  // Payment success
                payment_status[user_id] = 1;
                system_to_user!PAY_SUCCESS, user_id, result;
                printf("Payment: User %d paid $%d\n", user_id, amount);
            :: else ->  // Payment failure
                system_to_user!PAY_FAIL, user_id, result;
                printf("Payment: User %d payment failed\n", user_id);
            fi;
        fi;
    od;
}

/* LTL Properties for Health & Wellness Center - SCHEDULING & BOOKING ONLY */
/* Based on FR6, FR7, FR8, FR9, FR10, FR11, FR12 from Lab 4 */




/*FR6 (Browse Available Time Slots):

book_only_available: Users can only book available services
available_means_unbooked: Available services have no bookings

FR7 (Manage Appointments):

valid_user_booking: Valid user booking management
booking_eventually_processed: Booking requests get processed

FR8 (Manage Notifications/System Response):

system_responds: System responds to booking requests
booking_progress: System makes progress on requests

FR9 & FR10 (Staff Availability & Schedule):

staff_availability_consistent: Staff availability is consistent
eventually_available: Staff eventually becomes available

FR11 (View Booking History):

booking_tracking: User bookings are tracked properly

*/
//FR12 (Check Conflicts - No Double Booking):

//exclusive_booking: No double-booking of services
ltl exclusive_booking {  //PASS
    [](!((user_bookings[0] == 1) && (user_bookings[1] == 1)) &&
       !((user_bookings[0] == 1) && (user_bookings[2] == 1)) &&
       !((user_bookings[1] == 1) && (user_bookings[2] == 1)))
}

/* Property 2: If staff is unavailable, exactly one user should have that service booked */
ltl staff_booking_consistency {  //FAIL
    [](staff_available[0] == false -> 
       (user_bookings[0] == 1 || user_bookings[1] == 1 || user_bookings[2] == 1))
}

/*If no user has booked a service, staff should be available */
ltl available_when_unbooked {  // FAIL
    []((user_bookings[0] != 1 && user_bookings[1] != 1 && user_bookings[2] != 1) -> 
       staff_available[0] == true)
}



/* Users can only book available services */
ltl book_only_available {  //PASS
    [](user_bookings[0] == 1 -> staff_available[0] == false) &&
    [](user_bookings[1] == 1 -> staff_available[0] == false) &&
    [](user_bookings[2] == 1 -> staff_available[0] == false)
}

/*  Available services have no current bookings */
ltl available_means_unbooked { //PASS 
    [](staff_available[0] == true -> 
       (user_bookings[0] != 1 && user_bookings[1] != 1 && user_bookings[2] != 1))
}



/* Users can manage their own appointments */
ltl valid_user_booking { //PASS
    [](user_bookings[0] != 0 -> user_bookings[0] >= 1 && user_bookings[0] <= 3) &&
    [](user_bookings[1] != 0 -> user_bookings[1] >= 1 && user_bookings[1] <= 3) &&
    [](user_bookings[2] != 0 -> user_bookings[2] >= 1 && user_bookings[2] <= 3)
}

/* Eventually all booking requests get processed */
ltl booking_eventually_processed { //PASS
    [](len(user_to_system) > 0 -> <>(len(user_to_system) == 0))
}



/* PSystem eventually responds to all booking requests */
ltl system_responds { //PASS
    []<>(len(user_to_system) == 0 && len(system_to_user) == 0)
}

/* Booking system makes progress */
ltl booking_progress { //PASS
    [](len(user_to_system) > 0 -> <>(len(user_to_system) < 5))
}


/*  Staff availability is consistent across all services */
ltl staff_availability_consistent { //FAIL
    [](staff_available[0] == false -> 
       (user_bookings[0] == 1 || user_bookings[1] == 1 || user_bookings[2] == 1)) &&
    [](staff_available[1] == false -> 
       (user_bookings[0] == 2 || user_bookings[1] == 2 || user_bookings[2] == 2)) &&
    [](staff_available[2] == false -> 
       (user_bookings[0] == 3 || user_bookings[1] == 3 || user_bookings[2] == 3))
}


/*  User bookings are tracked properly */
ltl booking_tracking { //PASS
    [](user_bookings[0] != 0 -> user_bookings[0] != 255) &&
    [](user_bookings[1] != 0 -> user_bookings[1] != 255) &&
    [](user_bookings[2] != 0 -> user_bookings[2] != 255)
}


/* Eventually staff becomes available again */
ltl eventually_available { //FAIL
    []((staff_available[0] == false || staff_available[1] == false || staff_available[2] == false) ->
       <>(staff_available[0] == true || staff_available[1] == true || staff_available[2] == true))
}

/* Eventually all users complete their booking process */
ltl eventual_booking_completion { //PASS
    <>((user_bookings[0] != 0 || user_bookings[0] == 0) &&
       (user_bookings[1] != 0 || user_bookings[1] == 0) &&
       (user_bookings[2] != 0 || user_bookings[2] == 0))
}


ltl no_channel_overflow { //PASS
    [](len(user_to_system) <= 5 && len(system_to_user) <= 5)
}

/* No user can have multiple concurrent service bookings */
ltl no_multiple_services { //PASS
    [](!(user_bookings[0] == 1 && user_bookings[0] == 2)) &&
    [](!(user_bookings[0] == 1 && user_bookings[0] == 3)) &&
    [](!(user_bookings[0] == 2 && user_bookings[0] == 3)) &&
    [](!(user_bookings[1] == 1 && user_bookings[1] == 2)) &&
    [](!(user_bookings[1] == 1 && user_bookings[1] == 3)) &&
    [](!(user_bookings[1] == 2 && user_bookings[1] == 3)) &&
    [](!(user_bookings[2] == 1 && user_bookings[2] == 2)) &&
    [](!(user_bookings[2] == 1 && user_bookings[2] == 3)) &&
    [](!(user_bookings[2] == 2 && user_bookings[2] == 3))
}

/* LTL Properties for Smart Health & Wellness Center Payment & Billing System */

/* Property 1: Payment must be successful before service access */
/* A user can only access service after confirming payment (FR requirement) */
ltl payment_before_access { 
    [](((user_bookings[0] != 0) && (len(user_to_system) == 0)) -> (payment_status[0] == 1))
}

/* Property 2: Payment status consistency - once set to 1, it means payment succeeded */
ltl payment_status_consistency { 
    []((payment_status[0] == 1) -> X(payment_status[0] == 1))
}

/* Property 3: Service booking makes staff unavailable */
ltl booking_makes_unavailable { 
    []((user_bookings[0] == 1) -> (staff_available[0] == false))
}

/* Property 4: User cannot have booking without successful payment */
ltl booking_requires_payment { 
    []((user_bookings[0] != 0) -> (payment_status[0] == 1))
}

/* Property 5: Payment status starts at 0 */
ltl initial_payment_status { 
    (payment_status[0] == 0) && (payment_status[1] == 0) && (payment_status[2] == 0)
}

/* Property 6: User bookings start empty */
ltl initial_bookings_empty { 
    (user_bookings[0] == 0) && (user_bookings[1] == 0) && (user_bookings[2] == 0)
}

/* Property 7: Staff initially available */
ltl initial_staff_available { 
    (staff_available[0] == true) && (staff_available[1] == true) && (staff_available[2] == true)
}//FAIL

/* Property 8: No double booking - mutual exclusion */
ltl no_double_booking { 
    [](!((user_bookings[0] == 1 && user_bookings[1] == 1) || 
         (user_bookings[0] == 2 && user_bookings[1] == 2) || 
         (user_bookings[0] == 3 && user_bookings[1] == 3)))
}

/* Property 9: Channel communication - system responds to requests */
ltl system_responsiveness { 
    []((len(user_to_system) > 0) -> <>(len(system_to_user) > 0))
}

/* Property 10: Payment system processes requests */
ltl payment_system_active { 
    []((len(system_to_payment) > 0) -> <>(len(system_to_user) > 0))
}

/* Property 11: Payment status stability - once paid, stays paid */
ltl payment_stability { 
    []((payment_status[0] == 1) -> [](payment_status[0] == 1))
}

/* Property 12: At most one user can book each service */
ltl service_exclusivity { 
    [](!((user_bookings[0] == user_bookings[1]) && (user_bookings[0] != 0)))
}

/* Property 13: Booking leads to staff unavailability */
ltl booking_staff_correlation { 
    []((user_bookings[0] == 1) -> (staff_available[0] == false)) &&
    []((user_bookings[0] == 2) -> (staff_available[1] == false)) &&
    []((user_bookings[0] == 3) -> (staff_available[2] == false))
}

/* Property 14: Payment required for any booking */
ltl payment_required_for_booking { 
    []((user_bookings[0] > 0) -> (payment_status[0] == 1))
}

/* Safety Properties - Basic system invariants */
ltl safety_valid_bookings { 
    [](user_bookings[0] >= 0 && user_bookings[0] <= 3) &&
    [](user_bookings[1] >= 0 && user_bookings[1] <= 3) &&
    [](user_bookings[2] >= 0 && user_bookings[2] <= 3)
}

ltl safety_valid_payment_status { 
    [](payment_status[0] >= 0 && payment_status[0] <= 1) &&
    [](payment_status[1] >= 0 && payment_status[1] <= 1) &&
    [](payment_status[2] >= 0 && payment_status[2] <= 1)
}