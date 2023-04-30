//
//  ContentView.swift
//  WhatsPlaying
//
//  Created by John Holland on 4/28/23.
//

import SwiftUI
import MediaPlayer

func cleanUpStringWithRegexes(input:String) ->String {
    var output = input
    
    do {
        let regex = try  NSRegularExpression(pattern:"\\(.*\\)$", options:[])
        
        output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
    } catch  {
        output = input
        print("regex failed")
    }
    do {
        let regex = try  NSRegularExpression(pattern:"\\[.*\\]", options:[])
        
        output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
    } catch  {
        print("2nd regex failed")
    }
    return output
}




func fixStringForURL(input:String)->(_:String) {
    
    var output = input
    
    output.replace(" ", with: "_")
    return output.addingPercentEncoding(
        withAllowedCharacters: .urlQueryAllowed
    ) ?? "error encoding"
}


func getCurrPlaying()->(title:String, artist: String, album: String) {
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    if let nowPlayingItem = musicPlayer.nowPlayingItem {
        let titleString: String = nowPlayingItem.title ?? "no title value"
        
        return (
            titleString,nowPlayingItem.artist ?? "error getting artist",
            nowPlayingItem.albumTitle ?? "error getting album")
    } else {
        print("Nothing's playing")
        return ("Nothing", "Nobody", "No album")
    }
}

func getWikipediaURL()->String {
    let preferredLanguage : String = Locale.current.language.languageCode?.identifier ?? "en"
    //var languageCode = "en"

   
    
    return "https://" + preferredLanguage + ".wikipedia.org/wiki/"
}

let wikiUrl = "https://en.wikipedia.org"
let wikiWikiUrl =   getWikipediaURL()



struct ContentView: View {
    
    @Environment(\.openURL) private var openURL
    
    @State var currentTitle = "Nothing Playing"
    @State var currentArtist = "Nothing Playing"
    @State var currentAlbum = "Nothing Playing"
    @State var currentTitleForWiki = "initial"
    @State var currentArtistForWiki = "initial_artist"
    @State var currentAlbumForWiki  = "initial_album"
    
    @State var currentTitleURLForWiki = URL(string:wikiUrl)!
    
    @State var currentArtistURLForWiki = URL(string:wikiUrl)!
    
    @State var currentAlbumURLForWiki = URL(string:wikiUrl)!
    
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        VStack {
            Text("Wikipedia entries on what's playing:").bold().font(.title)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .inactive {
                        print("Inactive")
                    } else if newPhase == .active {
                        print("Active")
                        currentTitle = getCurrPlaying().title
                        currentArtist = getCurrPlaying().artist
                        currentAlbum = getCurrPlaying().album
                        
                        currentTitleForWiki = fixStringForURL(input: cleanUpStringWithRegexes(input:currentTitle))
                        currentArtistForWiki = fixStringForURL(input:cleanUpStringWithRegexes(input: currentArtist))
                        currentAlbumForWiki = fixStringForURL(input:cleanUpStringWithRegexes(input: currentAlbum))
                        
                        currentTitleURLForWiki = URL(string:wikiWikiUrl + currentTitleForWiki) ?? URL(string:"https://www.yahoo.com")!
                        currentArtistURLForWiki = URL(string:wikiWikiUrl + currentArtistForWiki) ?? URL(string:"https://www.cnn.com")!
                        currentAlbumURLForWiki = URL(string:wikiWikiUrl + currentAlbumForWiki) ?? URL(string:"https://google.com")!
                        
                        
                    } else if newPhase == .background {
                        print("Background")
                    }
                }
            
            
            Text("Song:")
            Button(currentTitle) {
                    openURL(currentTitleURLForWiki)
            }
            Text("By:")
            
            Button(currentArtist) {
                    openURL(currentArtistURLForWiki)
            }
            
            Text("From album:")
            Button(currentAlbum) {
                    openURL(currentAlbumURLForWiki)
            }
            
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
