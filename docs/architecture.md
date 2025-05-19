# System Architecture

## Process Model
```
┌──────────┐     ┌────────────────┐     ┌────────────────┐
│  User(0) │────>│                │────>│                │
│  User(1) │────>│ BookingSystem  │────>│ PaymentSystem  │
│  User(2) │────>│                │────>│                │
└──────────┘     └────────────────┘     └────────────────┘
      ▲                  │                      │
      └──────────────────┴──────────────────────┘
                    (responses)
```

## Channel Architecture
| Channel | Direction | Buffer | Fields |
|---------|-----------|--------|--------|
| `user_to_system` | User → Booking | 5 | mtype, user_id, service_id |
| `system_to_user` | Booking/Payment → User | 5 | mtype, user_id, result |
| `system_to_payment` | Booking → Payment | 5 | mtype, user_id, amount |

## State Variables
- `staff_available[3]` — per-service staff availability
- `user_bookings[3]` — per-user current booking
- `payment_status[3]` — per-user payment confirmation
