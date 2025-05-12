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
