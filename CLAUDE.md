# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Crazy Brag: a three-card brag variant for iOS (iPhone + iPad, landscape only), written in Swift 5 with SpriteKit. Single Xcode project, one shared scheme (`CrazyBrag`), no third-party dependencies, no linter.

## Commands

```sh
# Build
xcodebuild build -project CrazyBrag.xcodeproj -scheme CrazyBrag \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'

# All unit tests (skip the template-only UI tests)
xcodebuild test -project CrazyBrag.xcodeproj -scheme CrazyBrag \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' \
  -only-testing:CrazyBragTests

# One test class / one test method
... -only-testing:CrazyBragTests/HandResolverTests
... -only-testing:CrazyBragTests/HandResolverTests/testMethodName
```

- Pass `OS=` explicitly in the destination. Without it xcodebuild assumes the latest runtime and fails with "Unable to find a device" if that device name only exists on an older runtime.
- The unit tests are hosted by the app, so the app must launch for them to run; a launch crash shows up as "The test runner crashed before establishing connection".
- The app uses the UIScene lifecycle (required from iOS 27): `UIApplicationSceneManifest` in `CrazyBrag/Info.plist` loads `Main.storyboard` and names `SceneDelegate`. The rest of the Info.plist is generated from `INFOPLIST_KEY_*` build settings.
- The app version is `MARKETING_VERSION` in `project.pbxproj`; release commits are named after it (e.g. `v1.00.05`).

## Architecture

Model–View–Presenter, with the presenter running a state machine that paces the model.

**Model (`CrazyBrag/model/`)** — pure Foundation, no SpriteKit; this is what the unit tests cover.
- `Model` is a step-driven state machine (`GameState`: selectDealer → deal → reveal → turnStart ⇄ turnEnd → showHands → scoreRound → updateLives → …). Each call to `updateState()` performs exactly one step and reports it through the `GameListener` protocol. The model never advances itself; something external must keep calling `updateState()`.
- `School` owns the players, dealer rotation, lives, and picking the round's losers. `Player` delegates its move to an `AI` (`play(middle:) -> Turn`).
- A `Turn` is either `.swap(hand:middle:)` (one card) or `.all(downIndex:)` (swap all three, leaving one face down).
- Scoring: `HandResolver` scores a full three-card hand into a `BragHandScore` (type + comparable integer score). `PossibleHandResolver` scores what is visible when one card is face down. `HandGenerator` enumerates every possible turn with resulting hand and middle scores; AIs choose from that list.
- All computer players use `OneDownAI`. The other AIs in `AI.swift` are experiments/baselines. The human is `HumanAI`, whose `turn` is filled in by the presenter before the model asks for it.

**Presenter (`CrazyBrag/*.swift`)**
- `GamePresenter` implements `GameListener`. Each listener callback logs via `GameUpdateLogger` and switches to a matching `PlayState` subclass (`*State.swift`, one per file).
- A `PlayState` has `enter()` / `update()` / `exit()`. `enter()` drives the view (animations, messages, sounds) and sets `presenter.gameUpdateFrequency`; `update()` is called on that interval from the SpriteKit frame loop and typically calls `presenter.model.updateState()` to move the game on. So the delay between game steps is controlled by each state, not the model. States that wait for the user (end of round, game over) show the continue button instead of advancing in `update()`.
- Human input: `GameScene` forwards card touches to `GamePresenter.handleTouch`, which keeps `model.selectedCards`, validates via the model, and once a complete swap or all-in is selected sets `humanAI.turn` and calls `updateState()`. Touches are only accepted while `model.isPlayersTurn` is set by `HumanTurnStartedState`.
- To add a game event: add it to `GameListener`, emit it from `Model`, add it to `GameUpdateLogger`, and add a `PlayState` that `GamePresenter` switches to.

**View (`CrazyBrag/view/`)**
- `GameScene` implements the `GameView` protocol, the only thing the presenter and states talk to. `StartScene`/`StartPresenter`/`StartView` are the same pattern for the animated title screen. `GameViewController` just presents `StartScene`.
- Cards are identified by `PlayingCard` across the boundary; the scene maps them to `CardSprite` nodes.

**Layout**
- Positions are hard-coded in a fixed logical coordinate space per device family: `IPhoneLayout` (932×430) and `IPadLayout`, both conforming to `TableLayout` (defined in `IPadLayout.swift`, along with the `Layer` z-position enum). Scenes use `scaleMode = .fill` to stretch to the real screen. `StartLayout` and `InformationLayout` do the same for the other screens.
- Seats: `-1` is the middle, `0` is the human, `1...` are computer players clockwise. iPhone has 4 computer players, iPad 5, so a new seat needs a position in both layouts.

**Background image** — `westerntown.jpg` is generated, not hand-drawn: `sh tools/background/build.sh` (needs Google Chrome and ImageMagick) runs `town.py` and writes `tools/background/out/westerntown.jpg`, which is then copied into the asset catalogue. Both scenes scale it to fill and pin it to the bottom edge, so the iPad shows the whole 4:3 image and the iPhone crops the top.

**Card images** — the 52 faces and `CardBack` are also generated: `sh tools/cards/build.sh` runs `cards.py` and writes 691×1056 PNGs to `tools/cards/out/cards`, named like the image sets (`KH.png`, `10D.png`, `CardBack.png`). Court cards are western characters (K sheriff, Q saloon lady, J outlaw) and aces are bullets. `CardSpriteNode` stretches whatever image it is given to the layout's card size, so keep that aspect ratio.

**Marked backs ("Howie's deck")** — deliberately, every card has its own back image (`BackKH`, `Back10D`, …, half the size of the faces) carrying marks that identify the card, so an observant player can read face-down cards. The left poker chip's colour gives the suit, and the whiskey glass level plus one blemish (dot, scratch or dog-eared corner) gives the rank; the full key is in the comment above `MARK_CHIP` in `tools/cards/cards.py`. Both decks are kept: `Settings.markedDeck` (UserDefaults key `markedDeck`, default `true`, exposed as the "Marked Deck" switch in the iOS Settings app via `Settings.bundle/Root.plist`) chooses between the per-card marked backs and the plain `CardBack`; `CardSpriteNode` reads it when a card node is created, so a change applies from the next scene.

**Persistence** — `Settings` wraps `UserDefaults` (games played/won); `Stats` turns those into win rate and rank title. `Settings.bundle` provides the iOS Settings app pages.

## Debug aids

- `DEBUG_AUTO_PLAY` in `view/GameViewController.swift` (DEBUG builds only): when `true`, the human seat plays random moves so a game runs unattended.
- FPS/node count overlays are on in DEBUG builds only.

## Tests

`CrazyBragTests/Hands.swift` holds shared named hand fixtures (`PrialOfAces`, etc.) used across the test classes; reuse or extend these rather than building hands inline.
