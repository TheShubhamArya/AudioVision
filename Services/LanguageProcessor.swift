//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/8/22.
//

import NaturalLanguage
import UIKit

class LanguageProcessor {
    
    // get text from image -> find proper nouns (like names) to ignore -> find spelling mistakes and correct words -> select word from correct words that is closest to the misspelled word -> replace it in the text
    
    public func getCorrectedText(for text: String) -> String {
        let wordsToIgnoreSet = findProperNounsToIgnore(with: text)
        let correctedString = correctMisspelledWords(for: text,ignoring: wordsToIgnoreSet)
        return correctedString
    }
    
    private func findProperNounsToIgnore(with text: String) -> Set<String> {
        
        var wordsToIgnoreSet = Set<String>()

        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag, tags.contains(tag) {
                wordsToIgnoreSet.insert(String(text[tokenRange]))
//                print("\(text[tokenRange]): \(tag.rawValue)")
            }
            
            return true
        }
        return wordsToIgnoreSet
    }
    
    private func getClosestMatchingWord(for word: String, with guesses: [String])->String{
        let embed = NLEmbedding.wordEmbedding(for: .english)
        if guesses.isEmpty {
            return word
        }
        var minDistance = embed?.distance(between: word, and: guesses[0])
        var wordWithMinDistance = guesses[0]
        for guess in guesses {
            let distance = embed?.distance(between: word, and: guess)
            if Double(distance ?? 0) < Double(minDistance ?? 0){
                wordWithMinDistance = guess
                minDistance = distance
            }
        }
        
        return wordWithMinDistance
    }
    
    private func correctMisspelledWords(for text: String,ignoring wordsToIgnore: Set<String>) ->String {
//        print(text)
        let textChecker = UITextChecker()
        let nsString = NSString(string: text)
        let stringRange = NSRange(location: 0, length: nsString.length)
        var offset = 0
        var correctedText = text
        
        repeat {
            let wordRange = textChecker.rangeOfMisspelledWord(in: text, range: stringRange, startingAt: offset, wrap: false, language: "en" )
            
            // check if the loop range exceeds the string length
            guard wordRange.location != NSNotFound else {
                break
            }

            let misspelledWord = nsString.substring(with: wordRange)
            
            if wordsToIgnore.contains(misspelledWord) {
                offset = wordRange.upperBound
            } else {
                let guesses = textChecker.guesses(forWordRange: wordRange, in: text, language: "en") ?? [misspelledWord]
                
                print(misspelledWord, guesses)
                let closestGuess = getClosestMatchingWord(for: misspelledWord, with: guesses)
                correctedText = correctedText.replacingOccurrences(of: misspelledWord, with: closestGuess)
                
                offset = wordRange.upperBound
            }
           
        } while true
//        print(correctedText)
        return correctedText
    }
    
    public func getEmojiSentiment(with input: String) -> String{
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = input

        let (sentiment, _) = tagger.tag(at: input.startIndex, unit: .paragraph, scheme: .sentimentScore)
        let score = Double(sentiment?.rawValue ?? "0") ?? 0
        
        let emojiStr = sentimentScoreToEmoji(score)
        
        return emojiStr
    }
    
    private func sentimentScoreToEmoji(_ score: Double) -> String{
        if score > 0.85 {
            return "😁"
        } else if score > 0.7 {
            return "😄"
        } else if score > 0.5 {
            return "😃"
        } else if score > 0.3 {
            return "😀"
        } else if score > 0.15 {
            return "🙂"
        } else if score > 0 {
            return "😶"
        } else if score > -0.15 {
            return "😐"
        } else if score > -0.3 {
            return "😕"
        } else if score > -0.45 {
            return "☹️"
        } else if score > -0.6 {
            return "😣"
        } else if score > -0.75 {
            return "😖"
        } else {
            return "😫"
        }
    }
    
    func embedCheck(word: String){
        // Get the OS embeddings for the given language
        let embedding = NLEmbedding.wordEmbedding(for: .english)
        
        // Find the 5 words that are nearest to the input word based on the embedding
        let res = embedding?.neighbors(for: word, maximumCount: 5)
        // Print the words
        print(res ?? [])
    }
    
    func retrieveNeighebors() {
        
    }
    
}
