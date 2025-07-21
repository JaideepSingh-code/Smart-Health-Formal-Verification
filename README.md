# Smart Health & Wellness Center — Formal Verification

Formal modeling and verification of a Smart Health & Wellness Center booking and payment system using SPIN model checker and Promela.

## Overview
This project models the concurrent booking, payment, and service-access workflows of a health center using Promela processes, then verifies safety and liveness properties via LTL model checking in SPIN.

## Tech Stack
- **Modeling Language**: Promela
- **Model Checker**: SPIN
- **Properties**: LTL (Linear Temporal Logic)
- **Visualization**: iSpin GUI

## Key Features
- Concurrent multi-user booking with mutual exclusion
- Payment gateway integration with success/failure paths
- Staff availability management with conflict detection
- 25+ LTL properties covering safety, liveness, and fairness

## Project Structure
```
models/              - Promela process definitions
  model.pml          - Complete integrated model
  user_process.pml   - User process (booking + payment flow)
  booking_system.pml - Booking system server process
  payment_system.pml - Payment gateway process
properties/          - LTL property specifications
  scheduling_properties.pml - Booking & scheduling (FR6-FR12)
  payment_properties.pml    - Payment & billing verification
  safety_properties.pml     - System invariants
results/             - Verification results and analysis
docs/                - Project reports and requirements
```

## Running Verification
```bash
# Verify a single property
spin -a -f '!(exclusive_booking)' models/model.pml
gcc -o pan pan.c
./pan -a -N exclusive_booking

# Run all properties
./run_verification.sh
```

## Verification Summary
- **21 properties PASS** — safety, payment, booking exclusivity
- **4 properties FAIL** — reveal genuine concurrency bugs (no cancellation path, race conditions)

## Team
- Jaideep Singh
