//
//  wordsAndSentences.swift
//  Journals
//
//  Created by Paco Sun on 2023-09-15.
//

import Foundation
import SwiftUI

// Mood array
let descriptions = [String(localized: "sad"),
                    String(localized: "melancholic"),
                    String(localized: "frustrated"),
                    String(localized: "concerned"),
                    String(localized: "nostalgic"),
                    String(localized: "calm"),
                    String(localized: "angry"),
                    String(localized: "livid"),
                    String(localized: "happy"),
                    String(localized: "elated"),
                    String(localized: "joyful"),
                    String(localized: "content"),
                    String(localized: "motivated"),
                    String(localized: "relieved"),
                    String(localized: "celebratory"),
                    String(localized: "energetic"),
                    String(localized: "optimistic")
]

// Cheerup messages at the end of summary
var cheerUpMessages: [String: [String]] = [
    "positive":[String(localized: "Keep nurturing those moments of joy, and let the beauty of life's small wonders always brighten your path. Keep up the good work of introspecting your emotional experiences!"),
                String(localized: "Embrace the happiness in these fleeting moments, and may your journey be forever illuminated by the radiance of life's simple pleasures. Carry on with your practice of thoughtful self-feeling examination!"),
                String(localized: "Stay attuned to the enchanting symphony of life's small delights, and let the melody of happiness accompany you each step of the way. Persist in your pursuit of understanding your feelings!"),
                String(localized: "Cherish these fragments of bliss, and may your days be forever adorned with the jewels of life's modest treasures. Continue your journey of self-emotional exploration!"),
                String(localized: "Your ability to find joy in life's little marvels is a gift; keep unwrapping it and delighting in the magic that surrounds you. Stay dedicated to reflecting your emotions!"),
                String(localized: "May the tapestry of your days be woven with the threads of happiness found in the intricacies of life's miniature wonders. Persist in your endeavor to reflect on your emotions!"),
                String(localized: "Your heart's receptivity to life's small joys is truly remarkable; keep your spirit open to the abundance of happiness that exists all around you. Sustain your habit of introspective thinking about your feelings!"),
                String(localized: "As you journey through life, may you always find solace and elation in the embrace of the gentle moments that grace your path. Stay committed to introspecting on your emotions!"),
                String(localized: "Let the kaleidoscope of happiness formed by life's petite treasures continue to infuse your days with vibrant colors and radiant smiles. Continue contemplating your emotions!"),
                String(localized: "Stay on this beautiful path of cherishing life's simplicity, and may the wellspring of joy within you never run dry. Keep reflecting your feelings!")],
    
    "balanced":[String(localized: "Remember that life is a tapestry of various emotions, and finding equilibrium amidst the ups and downs is a commendable endeavor. Stay the course in your endeavor to understand your emotions!"),
                String(localized: "Embrace the ebb and flow of life's moments, for in the balance lies the tapestry that forms your unique journey. Sustain your efforts to delve into the depths of your feelings!"),
                String(localized: "Life's path is a blend of diverse experiences; let the neutrality of this moment guide you through the intricate weave of emotions. Continue the process of self-discovery through emotional reflection!"),
                String(localized: "Amidst the shades of gray, seek the nuances that add depth to your days, and let each hue contribute to the canvas of your story. Carry on with your emotional introspection!"),
                String(localized: "Just as a scale requires both sides for balance, your journey encompasses a range of emotions that shape the person you're becoming. Keep up the habit of pondering your emotions!"),
                String(localized: "Find comfort in the neutrality of this moment, for it's a canvas upon which you can paint the spectrum of emotions that color your life. Continue your journey of self-feeling exploration!"),
                String(localized: "The middle ground between highs and lows is where you discover the stability that can support you as you navigate life's twists and turns. Stay dedicated to understanding your emotional landscape!"),
                String(localized: "Life's pendulum swings between various feelings; use the equilibrium as an opportunity to reflect on the richness of your experiences. Persist in your practice of self-emotional exploration!"),
                String(localized: "In this moment of neutrality, take a breath and appreciate the mosaic of emotions that combine to create the masterpiece of your existence. Stay on the path of self-discovery through feeling contemplation!"),
                String(localized: "Just as a compass points to true north, your emotional equilibrium guides you through the ever-changing landscapes of your journey. Keep on examining and contemplating your emotions!")],
    
    "negative":[String(localized: "Adversity is but a chapter in the grand story of your life; with each challenge, you gather the ink to write more inspiring chapters ahead."),
                String(localized: "Amidst the challenges, remember that you possess the strength to shape your narrative and emerge from adversity with newfound wisdom."),
                String(localized: "Difficult moments are threads in the fabric of resilience; each challenge you face weaves a tapestry of strength that fortifies your spirit."),
                String(localized: "'Hardwork outweighs talent - every time.' - Kobe Bryant"),
                String(localized: "In the shadows, you find the contrast that makes the light shine even brighter. Your journey is composed of both, each enhancing the other."),
                String(localized: "Just as a phoenix rises from its ashes, your spirit too can soar above difficulties, fueled by the energy of transformation."),
                String(localized: "Storms may obscure the horizon, but beneath the clouds lies a landscape of opportunities waiting for your discovery."),
                String(localized: "The beauty of life's mosaic is its diversity of emotions. Even in tough times, your canvas is being painted with hues of growth and resilience."),
                String(localized: "The road may be tough at times, but your resilience is an unwavering guide that leads you through the darkest of moments."),
                String(localized: "When life's rhythm falters, embrace the dissonance, for it's through these moments that the symphony of your life gains depth and beauty."),
                String(localized: "While the clouds may momentarily dim the sky, remember that the sun's brilliance will break through once again, lighting your path.")]
]

let moodTexts = [String(localized: "Sad/Awful"),
                 String(localized: "Melancholic"),
                 String(localized: "Frustrated"),
                 String(localized: "Worried/Anxious"),
                 String(localized: "Nostalgic"),
                 String(localized: "Calm/Contemplative"),
                 String(localized: "Angry/Mad"),
                 String(localized: "Livid"),
                 String(localized: "Happy"),
                 String(localized: "Elated"),
                 String(localized: "Joyful/Hopeful"),
                 String(localized: "Content/Satisfied"),
                 String(localized: "Motivated"),
                 String(localized: "Relieved"),
                 String(localized: "Celebratory"),
                 String(localized: "Excited/Energetic"),
                 String(localized: "Optimistic")
]

let weatherIcons: [String: AnyView] = ["Clouds": AnyView(Image(systemName: "cloud").resizable().frame(width: 40, height: 27)),
                                       "Clear": AnyView(Image(systemName: "sun.max").resizable().frame(width: 40, height: 40)),
                                       "Snow": AnyView(Image(systemName: "snowflake").resizable().frame(width: 40, height: 40)),
                                       "Rain": AnyView(Image(systemName: "cloud.rain").resizable().frame(width: 40, height: 40)),
                                       "Drizzle": AnyView(Image(systemName: "cloud.drizzle").resizable().frame(width: 40, height: 40)),
                                       "Mist": AnyView(Image(systemName: "cloud.fog").resizable().frame(width: 40, height: 40)),
                                       "Smoke": AnyView(Image(systemName: "smoke").resizable().frame(width: 40, height: 30)),
                                       "Haze": AnyView(Image(systemName: "sun.haze").resizable().frame(width: 40, height: 40)),
                                       "Dust": AnyView(Image(systemName: "sun.dust").resizable().frame(width: 40, height: 40)),
                                       "Fog": AnyView(Image(systemName: "cloud.fog").resizable().frame(width: 40, height: 40)),
                                       "Sand": AnyView(Image(systemName: "sun.dust").resizable().frame(width: 40, height: 40)),
                                       "Ash": AnyView(Image(systemName: "sun.dust").resizable().frame(width: 40, height: 40)),
                                       "Tornado": AnyView(Image(systemName: "tornado").resizable().frame(width: 35, height: 40)),
                                       "Squall": AnyView(Image(systemName: "wind").resizable().frame(width: 40, height: 35))]
