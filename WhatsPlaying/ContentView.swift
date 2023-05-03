//
//  ContentView.swift
//  WhatsPlaying
//
//  Created by John Holland on 4/28/23.
//

import SwiftUI
import MediaPlayer

func checkIfWikiCanOpen(url: URL) async  throws ->Bool {
    let url = url
    let (_, response) = try await URLSession.shared.data(from: url)
    
    
    if let httpResponse = response as? HTTPURLResponse {
        let statusCode = httpResponse.statusCode
        print(statusCode)
        if (statusCode == 404) {
            return false
        }
        else {
            return  true
        }
    }
   // something bad happened
    return false
}
           


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
    
    @State var cantOpenArtist = false
    @State var showArtistCantOpen = false
    @State var cantOpenTitle = false
    @State var showTitleCantOpen = false
    @State var cantOpenAlbum = false
    @State var showAlbumCantOpen = false
    @State var wikiUrl =  "https://en.wikipedia.org/wiki/"
    
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        VStack {

            Spacer()
           
            Text(NSLocalizedString("main_heading" , comment: "Wikipedia entries on what's playing:")).bold().font(.title).multilineTextAlignment(.center).padding()
                .onChange(of: scenePhase) {
                    newPhase in
                    Task {
                        cantOpenArtist = try await !checkIfWikiCanOpen(url: currentArtistURLForWiki)
                        cantOpenTitle = try await !checkIfWikiCanOpen(url: currentTitleURLForWiki)
                        cantOpenAlbum = try await !checkIfWikiCanOpen(url: currentAlbumURLForWiki)
                    }
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
                        let currentAlbumForWiki = fixStringForURL(input:cleanUpStringWithRegexes(input: currentAlbum))
                        
                        currentTitleURLForWiki = URL(string:wikiUrl + currentTitleForWiki) ?? safeUrl
                        currentArtistURLForWiki = URL(string:wikiUrl + currentArtistForWiki) ?? safeUrl
                        currentAlbumURLForWiki = URL(string:wikiUrl + currentAlbumForWiki)  ?? safeUrl
                        
                        
                    } else if newPhase == .background {
                        print("Background")
                    }
                }
               
    
            Text(NSLocalizedString("song", comment:"Song:")).font(.title)
            Button(currentTitle) {
                if  !cantOpenTitle{
               openURL(currentTitleURLForWiki)
                } else {
                    showTitleCantOpen = true
                    print("can't open this  song")
                }
            }.font(.title)
                .alert("Wikipedia cannot open this song", isPresented: $showTitleCantOpen){
                    Button("OK", role: .cancel) {
                        showTitleCantOpen = false
                    }
                }
            Text(NSLocalizedString("by", comment:"By:")).font(.title)
            
            Button(currentArtist) {
                    if  !cantOpenArtist{
                   openURL(currentArtistURLForWiki)
                    } else {
                        showArtistCantOpen = true
                        print("can't open this  artist")
                    }
            }.font(.title)
                .alert("Wikipedia cannot open this artist", isPresented: $showArtistCantOpen){
                    Button("OK", role: .cancel) {
                        showArtistCantOpen = false
                    }
                }
            
            
            Text(NSLocalizedString("album", comment:"Album:")).font(.title)
            Button(currentAlbum) {
                    if  !cantOpenAlbum{
               openURL(currentAlbumURLForWiki)
                } else {
                    showAlbumCantOpen = true
                    print("can't open this album")
                }
        }.font(.title)
            .alert("Wikipedia cannot open this album", isPresented: $showAlbumCantOpen){
                Button("OK", role: .cancel) {
                    showAlbumCantOpen = false
                }
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
