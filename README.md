Spotify-Analysis
=============
### STA 141B
### Authors: Franklin Shih, Junzhe Zhu, Nilay Varshney, Sukhween Bhullar
------------------------------------------------

### Introduction:  
Our app is built for utilizing the Spotify API and performs summary, analysis and data visualization of popular artists and tracks. We built this shiny app under the idea that we want to explore the Spotify database to find interest and top tracks of different genres, analyze albums by your favorite artists, assess the mood of the song, and user’s idea for personal data visualization.  

### Data Description:  
The source of data comes from Spotify API. With the help of Spotifyr package on RStudio (https://cloud.r-project.org/web/packages/spotifyr/spotifyr.pdf ), we are able to retrieve desired data from Spotify and perform our analysis and data visualization on  audio features of tracks to learn about ist danceability energy, valence and more. We can even read more in-depth analysis data about tracks such as segments, beats, and tatums.

### Data Retrieval and Process:  

**User’s analysis:** Upon entering the user's credential, we will retrieve their top artist and top tracks and store them in a data table. Then, we will use track’s ID in the top track table as a key to retrieve those tracks’ feature analysis table. We extract the “valence” and “energy” columns to make a scatter plot, which represents the emotions of the songs they used to listen to. We utilized ggplot and various coloring for a better data visualization. We also acquired user’s saved tracks so we could get the information about their first saved track, the oldest song and the most popular song in their saved song list. 

**Most Popular Spotify Tracks per Category:** 
The app queries the list of Spotify categories for the United States to create a list of options in the “Category” dropdown menu. When a category is selected, a backend function produces a table of Spotify tracks and gets the IDs of every official playlist on Spotify. The top 100 tracks of each playlist is retrieved, and their IDs, names, artists, and popularity indices. Tracks with duplicate IDs are removed. The artists column is transformed to contain the names of each artist for each track. Then, the table is sorted by track popularity in descending order, and the ID and popularity columns are removed. Once the table is produced, the app fetches the top tracks in the table and displays them. The number of tracks displayed is the value of the “Number of Tracks” slider. If the slider is adjusted, the table is produced again, even if the selected category does not change.  

**Artist Album Analysis:** 
From the 'spotifyr' library, the get_spotify_access_token() was used to create a Spotify access token and get_artist_audio_features() was used to get a data frame of tracks and other attributes from a string input of the artist name or the artist Spotify ID . The “formattable”  and “shinydashboard” library is then used to create an aesthetic table, grouped by album names. Many backend calculations were performed, please refer to the code for more detailed notes.  

### User Guide:
**Note: Please refresh the app multiple times or wait a few minutes before the information is populated, due to the large amount of data takes time to process.**

**In order to use the Spotify APP, the user must possess a Spotify account to give authentication to the APP.**

**User’s analysis**: 
This portion of the app does not function because of the current issues with authentication, this is a running issue that is yet to be resolved, so this portion of the app only runs on your desktop. 
To access this feature, please refer to the ui.R and server.R files in the repo, then run them on your local machine. 
After doing this users should be able to access the features of our app after clicking on the tab on the navigation bar on the left. If the app is not working correctly, please close it and re-open should resolve the issues.

**Most Popular Spotify Tracks per Category:** Designed to give a playlist of popular tracks. 
1) When the user opens the widget, they will see a dropdown menu labeled “Category,” a slider labeled “Number of Tracks,” and a table with columns “name” and “artists.”   
2) The initial value for the menu will be “Top Lists,” the initial value for the slider will be 10, and the table will contain the names and artists of the 10 most popular tracks on Spotify in the “Top Lists” category.     
3) If the user wants to see the 10 most popular tracks on Spotify for a different category, they will select a different category from the dropdown menu, then click “Submit”. The list consists of all Spotify categories recognized in the United States.   
4) If the user wants to see a different number of the most popular tracks on Spotify for a certain category, they will adjust the slider to the appropriate value, then click “Submit”. Data is determined mainly based on the total number of streams, with more recent streams having a greater effect on the index.  
5)  It should be noted that anytime the category or number of tracks is updated, the resulting table will take anywhere from 5 to 15 seconds to load.

**Artist Album Analysis:** Designed to give in depth analysis of your favorite artist’s albums.  
Note: The default artist name has been set to "bts", but can be easily changed to an artist name of your choice
1)  Under the title “Artist Album Analysis” the user will see three fields titled: “Please type an artist name”, “Sort table by”, and “Arrange table”. The user must first enter an artist name in the input box titled “Please type an artist name”.   
2) Then, from the “Sort table by” drop down select which variable you want to sort your table by: “Release Year”, “Energy” , “Valence”, “Dance Level”. (for more information about Energy, Valence and Dance Level visit: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/).   
3) Proceed to the next input box titled “Arrange table by:”. This will allow you to arrange the selected value from the “Sort table by:”, select either “Ascending” or  “Descending” order.   
4) Now click “Submit”. After clicking this button, you will be able to see a table that analyzes your favorite artist’s albums.   
