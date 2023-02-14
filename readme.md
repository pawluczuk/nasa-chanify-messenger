## Demo project - daily NASA photo notification

### Description 

Send a daily push notification to a phone with a [NASA](https://api.nasa.gov/) APOD (Astronomy Picture of the Day) API.

Push notification is sent to mobile device using [Chanify](https://www.chanify.net/).

Set up:
* Lambda function - invoked every day at 10am 
* Lambda function fetches a new photo of the day via NASA API
* Notification is sent to mobile device with NASA photo of the day link and description
