/* Payment System Process */
/* Processes payment requests with non-deterministic success/failure */

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
