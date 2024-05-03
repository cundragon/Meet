# MEET Event Planning App

## Project Description
MEET is an event planning app designed to simplify the organization of meetups, targeting newer generations who value social connectivity. The app offers key features such as real-time coordination, location suggestions, and integration with popular social media platforms. It helps users stay on top of all their events while providing additional features within the app. Future plans include marketing investments, partnerships with event organizers and local businesses, and offering exclusive promotions to users.

## Features
- Home Page: Provides an overview of upcoming events and quick access to key features.
- Event Creation: Allows users to create new events with details such as date, time, location, and description.
- Event Details: Displays comprehensive information about each event, including attendees, agenda, and chat.
- Location: Suggests suitable locations for events based on user preferences and availability.
- Agenda: Enables users to create and manage event agendas, ensuring smooth event flow.
- Contact List: Allows users to manage their contacts and invite them to events.
- Chat: Facilitates real-time communication among event participants.
- Authentication: Ensures secure user authentication and data privacy.

## Installation
1. Clone the repository:
   ```
   git clone https://github.com/your-username/meet-app.git
   ```
2. Navigate to the project directory:
   ```
   cd Meet/meet
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Set up Firebase:
   - Create a new Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/).
   - Add your Firebase configuration to the following files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
     - `lib/firebase_options.dart`
5. Add your Google API key:
   - Obtain a Google API key from the Google Cloud Console.
   - Replace the placeholders with your API key in the following files:
     - `lib/EventDetails/maps.dart`
     - `lib/screens/SearchPlacesScreen.dart`
6. Run the app:
   ```
   flutter run
   ```

## Testing
The MEET app has undergone thorough testing to ensure that its features and functions operate smoothly and align with the set goals. The tests primarily target key features such as the Home Page, Event Creation, Event Details, Location, Agenda, Contact List, Chat, and Authentication. Multiple team members have conducted tests at various stages of development to ensure comprehensive examination. All aspects of the app have successfully passed the tests, with minor errors identified and addressed to enhance user experience and optimize performance.

## Inspection
The following items have been inspected:
- Authentication
- Display event details
- Event creation
- Event agenda
- Event permission settings
- Display chat
- Group chat permission settings

The inspection procedures include inspection meeting schedule, meeting format, resolution, and documentation. The results are favorable, with no issues found in any of the features as of now.

## Future Enhancements
- Integrate the app with popular calendar apps to allow users to easily add events to their calendars.
- Expand the user's profile section to include favorite events, date, location, time, etc., enabling users to connect with friends who have similar interests.
- Improve the synchronization of the chat feature.
- Display event locations directly within the app instead of redirecting to Google Maps.
- Enhance the user interface and color palette for a more visually appealing experience.

## Credits
This project is based on the work of Group 6: Bilal Suleman, Darshan Shet, Karol Cieslikowski, and Yusra Ahmed, as detailed in the Meet app Project Report from Spring 2023.



**Important Note:** Remember to add your personal Google API key in the following files:
- `lib/EventDetails/maps.dart`
- `lib/screens/SearchPlacesScreen.dart`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`
