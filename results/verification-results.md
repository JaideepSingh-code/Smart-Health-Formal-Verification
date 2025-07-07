# SPIN Verification Results

## Scheduling & Booking Properties

| Property | Status | Description |
|----------|--------|-------------|
| `exclusive_booking` | PASS | No double-booking of services |
| `book_only_available` | PASS | Users can only book available services |
| `available_means_unbooked` | PASS | Available services have no bookings |
| `valid_user_booking` | PASS | Booking values within valid range |
| `booking_eventually_processed` | PASS | All requests eventually processed |
| `system_responds` | PASS | System responds to all requests |
| `booking_progress` | PASS | System makes forward progress |
| `booking_tracking` | PASS | Bookings tracked correctly |
| `staff_booking_consistency` | **FAIL** | Staff unavailability doesn't guarantee booking |
| `available_when_unbooked` | **FAIL** | Race condition in availability check |
| `staff_availability_consistent` | **FAIL** | Cross-service consistency gap |
| `eventually_available` | **FAIL** | No staff release mechanism |

## Payment Properties

| Property | Status | Description |
|----------|--------|-------------|
| `payment_before_access` | PASS | Payment required before access |
| `payment_stability` | PASS | Payment status is monotonic |
| `booking_requires_payment` | PASS | No booking without payment |
| `service_exclusivity` | PASS | Mutual exclusion on services |
| `no_double_booking` | PASS | No concurrent same-service bookings |

## Safety Properties

| Property | Status | Description |
|----------|--------|-------------|
| `safety_valid_bookings` | PASS | Booking values in [0,3] |
| `safety_valid_payment_status` | PASS | Payment status in [0,1] |
| `no_channel_overflow` | PASS | Channel buffers respected |
| `initial_*` | PASS | All initial state properties hold |

## Analysis of Failures
The 4 failing properties reveal real design limitations:
1. **No cancellation/release** — once staff is marked unavailable, there's no path back
2. **Race conditions** — concurrent users can observe stale availability
3. **Missing invariant** — staff_available[i]=false doesn't imply exactly one booking exists

These are genuine concurrency bugs that would need model refinement to fix.
