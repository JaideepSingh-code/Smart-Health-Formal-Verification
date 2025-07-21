#!/bin/bash
# Run SPIN verification for all LTL properties

MODEL="models/model.pml"

echo "=== Smart Health & Wellness Center — SPIN Verification ==="
echo ""

# List of properties to verify
PROPERTIES=(
    "exclusive_booking"
    "book_only_available"
    "available_means_unbooked"
    "valid_user_booking"
    "booking_eventually_processed"
    "system_responds"
    "booking_progress"
    "booking_tracking"
    "payment_before_access"
    "payment_stability"
    "booking_requires_payment"
    "service_exclusivity"
    "safety_valid_bookings"
    "safety_valid_payment_status"
    "no_channel_overflow"
)

for prop in "${PROPERTIES[@]}"; do
    echo "--- Verifying: $prop ---"
    spin -a -f "!($prop)" "$MODEL" 2>/dev/null
    gcc -o pan pan.c -DMEMLIM=512 2>/dev/null
    ./pan -a -N "$prop" 2>/dev/null | grep -E "(errors|violated|acceptance)"
    rm -f pan pan.* _spin_nvr.tmp 2>/dev/null
    echo ""
done
