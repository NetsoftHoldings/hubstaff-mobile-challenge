# Hubstaff Test

This is my solution to the test. It has no dependencies, so you can simply download the project and run! 🏃🏻‍♂️

I decided to use an MVP architecture, because I had never used it before and I wanted to try something new. I think it fitted the problem quite well. 

I left several comments and warnings throughout the code base, to highlight things that need improvement. There are many error cases that are not currently handled, but the methods to deliver those errors to the user are in place. Other notes are listed below:

## Notes

- The app assumes that the radius in the data model is in meters

- Location permission:
    - [Apple's docs](https://developer.apple.com/documentation/corelocation/choosing_the_location_services_authorization_to_request) claim that the "When In Use" permission is enough to get geofencing to work; however, [other sources](https://www.raywenderlich.com/5470-geofencing-with-core-location-getting-started) state that the "Always" permission is needed; more investigation is needed here, so please follow the instructions below:
    - On iOS 12 and 13, please use the "Always" location permission
    - On iOS 14, please use the "When In Use" location permission

- 500 meters accuracy
    - The app is set up to receive only significant location change updates, when the user moves roughly 500 meters; this is to save battery
    - However, this also means that some of the geofencing notifications may take longer to be triggered than expected; the first site (called "Office") is a notable example; the exit notification gets triggered after the user has moved several hundred meters away from the area and this is quite consistent
    - In my opinion, this is an incongruency in the way location services work on iOS (the distance filter should not affect a geofence; requesting the user's most detailed location, instead of only significant change updates, should not affect geofencing, etc.), and would require a discussion with the product team to undertsand what is the acceptable level of inaccuracy in the app

- Provisional notifications
    - Apple's new recommended way of asking users for notification permissions is through [provisional notifications](https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications?language=objc) and that's what I used
    - This means that the first geofencing notification is delivered silently, so check the notification center and accept the notifications to see all other notifications come through as expected
    - To me, this is another case where there needs to be a discussion of what is required by the app
    - If this is an app for workers, we get more leeway in terms of forcing users to grant the permissions we need; however, we still don't want to bombard users with permissions upon launching the app, so an onboarding flow would be best here
    - For now, provisional notifications are good enough

- Model-view-presenter
    - MVVM is overkill here, best for a rmore eactive approach; it would be more useful if we had a persistent store for the data
    - MVP helped with the "massive view controller problem", since it moved a lot of logic out of the `HTMapViewController`
    - MVP made it easier to implement other ways to visualize the data model if we wanted to, such as a table view with all the available sites, etc.
