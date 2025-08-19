# 🏢 Innerspace Coworking – Booking App  

## 📌 Overview  
A Flutter app to explore coworking spaces, view details, and book them easily. Users can search, filter, view on maps, and manage bookings.  

> **Note:** This project was developed with the assistance of AI tools to accelerate design, architecture, and code implementation.

---

## 🚀 Getting Started  

### Prerequisites  
- Flutter SDK (>=3.22.1)  
- Firebase project setup (Auth, Firestore, Cloud Messaging)  

### Features  
- **Splash Screen** – Show logo and navigate to Home  
- **Home Screen** – List coworking branches with name, location, price/hour  
  - Search by branch, city, or asset name  
  - Filter by city or price  
- **Map View** – Show all branches as markers dynamically  
- **Space Detail Screen** – Images, description, amenities, operating hours  
- **Booking Screen** – Select date/time slot, confirm booking  
- **My Bookings Screen** – View bookings with status (Upcoming / Completed)  
- **Notifications Screen** – Push notifications for booking updates  

---

## 🏗️ Architecture Decisions  
- **State Management:** Provider  
- **Database:** Firebase Firestore  
- **Auth:** Firebase Authentication  
- **Push Notifications:** Firebase Cloud Messaging  
- **Maps:** Google Maps Flutter  

---

## ⚡ Challenges Faced  
- Handling notifications across Android
