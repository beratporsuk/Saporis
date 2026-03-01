# Saporis

Saporis is a SwiftUI-based iOS social discovery app focused on venue exploration and check-ins.  
It combines real-world place data with a lightweight social layer (profiles, check-ins, comments).

## Features
- Venue discovery and search (Google Places)
- Location-aware experience (MapKit / CoreLocation)
- Check-in flow with photo + description
- Comments & social interactions stored in Firebase
- Modern SwiftUI UI with reusable components

## Tech Stack
- **Swift / SwiftUI**
- **Firebase** (Auth, Firestore, Storage)
- **Google Places API**
- **MapKit / CoreLocation**

## Security Notes
- Sensitive credentials (e.g., API keys) are **never committed** to the repository.
- Local configuration files are excluded via `.gitignore`.

## Getting Started
1. Clone the repo
2. Install dependencies (Swift Package Manager if used)
3. Add local config files (not tracked):
   - `GoogleService-Info.plist` (Firebase)
   - Any local API key configuration
4. Build & run on Xcode
   
