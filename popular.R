library(shiny)
library(httr)
library(jsonlite)
library(tidyverse)
library(spotifyr)

r_cat <- GET('https://api.spotify.com/v1/browse/categories',
             add_headers(Authorization = paste("Bearer", get_spotify_access_token())),
             query = list(country = 'US', locale = 'en_US', limit = 50))
json_cat <- content(r_cat, as = 'text')
from_json_cat <- fromJSON(json_cat)
cats <- from_json_cat$categories$items %>% select(name, id)

get_track_pop_cat <- function(cat) {
    cat_id <- cats %>% filter(name == cat) %>% select(id) %>% pull
    pl_ids <- get_category_playlists(cat_id, country = 'US', limit = 50)$id
    tracks <- NULL
    for (pid in pl_ids) {
        pl_tracks <- get_playlist_tracks(pid) %>% drop_na(track.id) %>%
            select(track.id, track.name, track.artists, track.popularity)
        tracks <- rbind(tracks, pl_tracks)
    }
    if(length(tracks) > 0) {
        tracks <- tracks %>% mutate(track.artists = {
            a <- NULL
            for(t_a in tracks$track.artists) {
                a <- c(a, str_c(t_a$name, collapse = ', '))
            }
            a
        }) %>% distinct(track.id, .keep_all = TRUE) %>%
            arrange(desc(track.popularity)) %>%
            transmute(name = track.name, artists = track.artists)
    }
    return(tracks)
}

ui <- fluidPage(
    titlePanel("Most Popular Spotify Tracks per Category"),
    sidebarLayout(
        sidebarPanel(
            selectInput("cat", "Category", cats$name),
            sliderInput("num", "Number of Tracks", min = 1, max = 30, value = 10)
        ),
        mainPanel(
            tableOutput('mpts')
        )
    )
)

server <- function(input, output) {
    output$mpts <- renderTable({
        gtpc <- get_track_pop_cat(input$cat)
        min <- min(input$num, length(gtpc$name))
        if(is.null(gtpc)) {
            shiny::showNotification("No tracks to show", type = "error")
            data.frame(name = c(""), artists = c(""))
        } else {
            gtpc %>% slice(1:min)
        }
    })
}

shinyApp(ui = ui, server = server)