# Boltstorm - Ongoing Portfolio Project
Boltstorm is a simple search app for Magic: The Gathering cards. You can search by partial name, get a list of results, and tap in to see card details.

This is an intentional exploration of spec-driven design with AI assistance. Rather than building a finished product (yet!), I'm focusing on how to work effectively with AI tooling and design thinking at the iOS level.

## SwiftUI symbolEffect Animation
Animation utilizes .drawOn for the search image and withAnimation for the entire view, with a semi-custom delayed effect.

See: [SearchEmptyView](Boltstorm/SearchEmptyView.swift)

https://github.com/user-attachments/assets/02b730e4-5d7d-4978-bd11-2bcf1c0fdf53

## Search Page
This I wrote on my own with occasional help from ChatGPT directly through Xcode. In Xcode 26 it's kind of just okay. It wasn't as robust as working through the terminal like via Claude Code. However, WWDC26 just launched and they've made what look like big improvements here. Xcode 27's agent integration seems to be better for development across the entire project; we'll see.

## One Spec-Driven Implementation (so far)
[Card Detail Screen](Specs/CardDetailScreenUltraplanSpec.md)
This entire page was built out in Claude Code plan mode. I used it with typical prompt questions to help me build the spec file, then validate all the spec plans, and finally make the implementation.

I was curious how it handles [Mana Symbols](https://scryfall.com/docs/api/colors)-- the card view should display card details in iOS native labels and images, and that includes mana symbols, which are images. Scryfall defines an API endpoint with all the known mana symbols, and URIs to .svg files for use. Claude actually suggested to use Andrew Gioia's free [mtg card symbol font](https://mana.andrewgioia.com/). In the implementation, it downloaded this font, added it to the project, and used the mana symbols correctly. It also noticed I wanted to use a `card/:id` endpoint, which it correctly identified was redundant because the main search results return all the necessary card data.

It also respected my request for the card art thumbnail to only take up 1/4th of the top of the screen. I suspect I can build this entire app through just Claude. My next screen I plan to implement through the Figma plugin for Claude Code, passing in a Figma URL as a UI spec. 

One design problem AI likely couldn't see: a font can be colored, and the basic text color isn't good enough for mana symbols. All the symbols are black right now. They should be multi-colored; for example, the green symbol has a round light-green background and a slightly darker green fill for the tree. In another update I'll ask Claude to fix this. I might implement the .svg links myself too just to see the difference.

