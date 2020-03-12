library(shiny)
library(tidyverse)
library(shinyWidgets)
library(dplyr)
library(spotifyr)
library(formattable)

ui <- fluidPage(
  titlePanel("Artist Album Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      h5("This app generates an analysis of all the playlists of a specific artist."),
      textInput(inputId="artist",
                label="Please type an artist name:"),
      selectInput(inputId= "sort",
                  label="Sort table by:",
                  choices=c("Release Year", "Energy","Valence", "Dance Level"),
                  selected= NULL),
      selectInput(inputId= "arrange",
                  label="Arrange table by:",
                  choices=c("Ascending", "Descending"),
                  selected= NULL),
      submitButton("Submit")
    ),
    mainPanel(
      formattableOutput("albumTable")
    )

  )
)

server <- function(input, output) {
  
  output$albumTable <- renderFormattable({
    # get the access token
    access_token <- get_spotify_access_token(client_id = Sys.getenv("SPOTIFY_CLIENT_ID"), 
                                             client_secret = Sys.getenv("SPOTIFY_CLIENT_SECRET"))
    
    # get the dataset for the specific input from the user
    dataset <- get_artist_audio_features(input$artist)
    
    # create a data table grouped by the album_name, 
      # then create averages for the energy, valence, dance, loudness, danceability, instrumentalness
      # for average_track_time to minutes, seconds and album_time convert to minutes
      # then calculate the mood categories 
    dataset_album_one<-dataset %>% 
      group_by(album_name, album_release_year, album_id) %>% 
      summarize(avg_energy=mean(energy), 
                avg_valence=mean(valence), 
                avg_dance=mean(danceability), 
                number_tracks=max(track_number),
                avg_loudness= mean(loudness), 
                avg_danceability= mean(danceability), 
                avg_instrumentalness= mean(instrumentalness),
                avg_track_time = (mean(duration_ms)/1000.0)/60.0,
                album_time = (sum(duration_ms)/(1000.0*60))) %>% 
      mutate(mood=case_when(
        (avg_valence<=.5 & avg_energy>=.5) ~ "Ambitious",
        (avg_valence>=.5 & avg_energy<=.5) ~ "Peaceful",
        (avg_valence <=.5 & avg_energy<=.5) ~ "Sad", 
        (avg_valence>=.5 & avg_energy>=.5) ~ "Happy", 
        TRUE ~ "Misc"
      ))
    
    time_calculator <- function(a){
      hours = floor(a/60)
      minutes = floor(a%%60)
      seconds = floor((a%%floor(a))*60)
      case_when(
        a >= 60 ~  sprintf("%01d:%02d:%02d", hours, minutes, seconds),
        a < 60 ~ sprintf("0:%02d:%02d", minutes, seconds)
      )
    }
    
    time_calculator2 <- function(a){
      minutes= floor(a)
      seconds = floor((a%%floor(a))*60)
      sprintf("%01d:%02d", minutes, seconds)
    }
    
    # from the above, grouped dataset, select the variables of interest
      # convert all album_times to hours, minutes, seconds
      # convert all avg-track_time to minutes, seconds
    albums_final<-dataset_album_one %>% 
      select(album_name, 
             album_release_year,
             number_tracks,
             album_time,
             avg_track_time,
             mood,
             avg_energy,
             avg_valence,
             avg_danceability) %>%
      mutate(album_time = as.character(time_calculator(album_time))) %>% 
      mutate(avg_track_time = as.character(time_calculator2(avg_track_time))) %>% 
      mutate_if(is.numeric, round, digits = 2) %>% 
      mutate(mood=as.factor(mood)) %>% 
      rename("Album Name"=album_name,
             "Release Year"=album_release_year,
             "Total Tracks"= number_tracks,
             "Average Track Time (min:sec)"=avg_track_time,
             "Album Duration (hr:min:sec)"= album_time,
             "Mood"=mood,
             "Valence" = avg_valence,
             "Energy" = avg_energy, 
             "Dance Level"=avg_danceability)
    
    #drop all the repeated Album Names
    albums_final<- albums_final[!duplicated(albums_final$`Album Name`), ]
    
    library(formattable)
    
    #now based on the input for the sorting method sort the datasets
    if(input$sort == "Release Year" && input$arrange =="Descending"){ #if the input is Release Year, then sort by Release Year
      albums_final <- albums_final %>%
        arrange(desc(`Release Year`)) 
    }else if(input$sort == "Energy" && input$arrange == "Descending"){ #if the input is Energy, then sort by Energy
      albums_final <- albums_final %>%
        arrange(desc(`Energy`))
    }else if(input$sort == "Valence" && input$arrange == "Descending"){ #if the input is Valence, then sort by Valence
      albums_final <- albums_final %>%
        arrange(desc(`Valence`))
    }else if(input$sort == "Dance Level" && input$arrange == "Descending"){ #if the input is Dance Level, then sort by Dance Level
      albums_final <- albums_final %>%
        arrange(desc(`Dance Level`))
    }else if(input$sort == "Release Year" && input$arrange == "Ascending"){ #if the input is Energy, then sort by Energy
      albums_final <- albums_final %>%
        arrange(`Release Year`)
    }else if(input$sort == "Energy" && input$arrange == "Ascending"){ #if the input is Valence, then sort by Valence
      albums_final <- albums_final %>%
        arrange(`Energy`)
    }else if(input$sort == "Valence" && input$arrange == "Ascending"){ #if the input is Dance Level, then sort by Dance Level
      albums_final <- albums_final %>%
        arrange(`Valence`)
    }else{ #if the input is Dance Level, then sort by Dance Level
      albums_final <- albums_final %>%
        arrange(`Dance Level`)
    }
    
    colorMatcher<-function(a){
      if(a== "Energetic"){
        "blac"
      }else if(a== "Ambitious"){
        "tomato"
      }else if(a=="Peaceful"){
        "tan1"
      }else{
        "darkred"
      }
    }
    
    formattable(albums_final, 
                align = c("l",rep("r", NCOL(albums_final) - 1)),
                list(
                  `ID` = formatter("span",
                                   style = ~ style(color="black"),
                                   font.weight = "bold"),
                  
                  `Album Name` = formatter("span",
                                           style = ~ style(color="black"),
                                           font.weight = "bold"),
                  
                  `Album Release Year` = formatter("span",
                                                   style= ~style(color="gray")),
                  
                  `Valence` = formatter("span",
                                        style = ~ style(color="black"),
                                        font.weight = "bold"),
                  
                  `Energy` = formatter("span",
                                       style = ~ style(color="black"),
                                       font.weight = "bold"),
                  
                  `Valence` = color_tile("olivedrab1", "olivedrab4"),
                  
                  `Energy` = color_tile("olivedrab1", "olivedrab4"),
                  
                  `Mood` = formatter("span", 
                                     style= x~ifelse(x== "Happy", style(color = "green", font.weight = "bold"),
                                                     ifelse(x=="Ambitious", style(color = "blue", font.weight = "bold"),
                                                            ifelse(x=="Peaceful", style(color = "purple", font.weight = "bold"),
                                                                   style(color = "gray", font.weight = "bold"))))
                                                      ),
                  
                  `Total Tracks` = formatter("span",
                                             style= ~style(color="black")),
                  
                  `Dance Level` = color_tile("olivedrab1", "olivedrab4"), 
                  
                  `Release Year` = color_tile("white", "tan")
                )
    )
  })
}

shinyApp(ui = ui, server = server)


