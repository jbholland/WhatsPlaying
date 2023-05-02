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

func getPreferredLanguage(locale:Locale)->String {
    let langCode = String(locale.identifier.dropLast(3))
    return langCode
    
    
}





struct ContentView: View {
    @Environment(\.locale) var locale
    @Environment(\.openURL) private var openURL
    
    @State var currentTitle = "Nothing Playing"
    @State var currentArtist = "Nothing Playing"
    @State var currentAlbum = "Nothing Playing"
    @State var currentTitleForWiki = "initial"
    @State var currentArtistForWiki = "initial_artist"
    @State var currentAlbumForWiki  = "initial_album"
    let safeUrl = URL(string:"https://en.wikipedia.org")!
    @State var currentTitleURLForWiki = URL(string:"https://en.wikipedia.org")!
    @State var currentArtistURLForWiki = URL(string:"https://en.wikipedia.org")!
    @State var currentAlbumURLForWiki = URL(string:"https://en.wikipedia.org")!
    
    
    @State var wikiUrl =  "https://en.wikipedia.org/wiki/"
    
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        VStack {

            Spacer()
            Text(NSLocalizedString("main_heading" , comment: "Wikipedia entries on what's playing:")).bold().font(.title).multilineTextAlignment(.center).padding()
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .inactive {
                        print("Inactive")
                    } else if newPhase == .active {
                        print("Active")
                        wikiUrl =   "https://" + getPreferredLanguage(locale: locale) + ".wikipedia.org/wiki/"
                          
                        currentTitle = getCurrPlaying().title
                        currentArtist = getCurrPlaying().artist
                        currentAlbum = getCurrPlaying().album
                        
                        let currentTitleForWiki = fixStringForURL(input: cleanUpStringWithRegexes(input:currentTitle))
                        let currentArtistForWiki = fixStringForURL(input:cleanUpStringWithRegexes(input: currentArtist))
                        var currentAlbumForWiki = fixStringForURL(input:cleanUpStringWithRegexes(input: currentAlbum))
                        
                        currentTitleURLForWiki = URL(string:wikiUrl + currentTitleForWiki) ?? safeUrl
                        currentArtistURLForWiki = URL(string:wikiUrl + currentArtistForWiki) ?? safeUrl
                        currentAlbumURLForWiki = URL(string:wikiUrl + currentAlbumForWiki)  ?? safeUrl
                        
                        
                    } else if newPhase == .background {
                        print("Background")
                    }
                }
            
    
            Text(NSLocalizedString("song", comment:"Song:")).font(.title)
            Button(currentTitle) {
                openURL(currentTitleURLForWiki)
            }.font(.title)
            Text(NSLocalizedString("by", comment:"By:")).font(.title)
            
            Button(currentArtist) {
                openURL(currentArtistURLForWiki)
            }.font(.title)
            
            Text(NSLocalizedString("album", comment:"Album:")).font(.title)
            Button(currentAlbum) {
                openURL(currentAlbumURLForWiki)
            }.font(.title)
            Spacer()
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
