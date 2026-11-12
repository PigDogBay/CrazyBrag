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
- Looky Looky actions: before making their move a player may take up to two of the three `TurnAction`s (`looky` at the face down middle card, `stashHand` for three new cards, `changeMiddle` to replace one middle card), each once a turn. `Model.canTake(action:)` / `takeLooky()` / `takeStashHand()` / `takeChangeMiddle(card:)` act on the current player while the model waits in `.turnEnd`, and report through `GameListener.actionTaken(player:action:)`. That is not a play state change: `GamePresenter.actionTaken` animates it in place (and shows a status message for a computer player). Stashed cards go to the bottom of the deck. The human takes actions with the three `ActionButtonNode`s next to their hand (`GamePresenter.handleAction`, positions in `TableLayout.actionButtons`); a computer player is asked by `Model.turnEnd` through `AI.chooseAction(middle:available:)`, one action per `updateState()` call, until it returns nil and the move is played (`AI.lookedAt(card:)` tells it the down card). `OneDownAI.chooseAction` holds the strategy: stash a hand going nowhere, always looky, stash before taking all three, change a useless or (out of spite) a good middle card. `OneDownAITests.tournament()` (rename to `testTournament` to run) plays action takers against non-takers.
- To add a game event: add it to `GameListener`, emit it from `Model`, add it to `GameUpdateLogger`, and add a `PlayState` that `GamePresenter` switches to.

**View (`CrazyBrag/view/`)**
- `GameScene` implements the `GameView` protocol, the only thing the presenter and states talk to. `StartScene`/`StartPresenter`/`StartView` are the same pattern for the animated title screen. `GameViewController` just presents `StartScene`.
- Cards are identified by `PlayingCard` across the boundary; the scene maps them to `CardSprite` nodes.

**Layout**
- Positions are hard-coded in a fixed logical coordinate space per device family: `IPhoneLayout` (932×430) and `IPadLayout`, both conforming to `TableLayout` (defined in `IPadLayout.swift`, along with the `Layer` z-position enum). Scenes use `scaleMode = .fill` to stretch to the real screen. `StartLayout` and `InformationLayout` do the same for the other screens.
- Seats: `-1` is the middle, `0` is the human, `1...` are computer players clockwise. iPhone has 4 computer players, iPad 5, so a new seat needs a position in both layouts.

**Background image** — `westerntown.jpg` is generated, not hand-drawn: `sh tools/background/build.sh` (needs Google Chrome and ImageMagick) runs `town.py` and writes `tools/background/out/westerntown.jpg`, which is then copied into the asset catalogue. Both scenes scale it to fill and pin it to the bottom edge, so the iPad shows the whole 4:3 image and the iPhone crops the top.

**Action button images** — `ActionLooky`, `ActionStash` and `ActionChange` are generated by `sh tools/icons/build.sh` (`icons.py`), written to `tools/icons/out`.

**Sounds** — `Yahoo.wav`, the cowboy's cry played when a player wins an extra life, is synthesised (glottal pulses through moving formant filters, then an imitation of an early 1980s arcade speech chip at 8 kHz / 8 bits; standard library Python only): `sh tools/sounds/build.sh` runs `yahoo.py` and writes `tools/sounds/out/Yahoo.wav`, plus a spectrogram `Yahoo.pgm` for checking it by eye. The other sounds in `CrazyBrag/sounds` are recordings.

**Card images** — the 52 faces and `CardBack` are also generated: `sh tools/cards/build.sh` runs `cards.py` and writes 691×1056 PNGs to `tools/cards/out/cards`, named like the image sets (`KH.png`, `10D.png`, `CardBack.png`). Court cards are western characters (K sheriff, Q saloon lady, J outlaw) and aces are bullets. `CardSpriteNode` stretches whatever image it is given to the layout's card size, so keep that aspect ratio.

**Marked backs ("Howie's deck")** — deliberately, every card has its own back image (`BackKH`, `Back10D`, …, half the size of the faces) carrying marks that identify the card, so an observant player can read face-down cards. The left poker chip's colour gives the suit, and the whiskey glass level plus one blemish (dot, scratch or dog-eared corner) gives the rank; the full key is in the comment above `MARK_CHIP` in `tools/cards/cards.py`. Both decks are kept: `Settings.markedDeck` (UserDefaults key `markedDeck`, default `true`, exposed as the "Marked Deck" switch in the iOS Settings app via `Settings.bundle/Root.plist`) chooses between the per-card marked backs and the plain `CardBack`; `CardSpriteNode` reads it when a card node is created, so a change applies from the next scene.

**Persistence** — `Settings` wraps `UserDefaults` (games played/won, plus the `markedDeck` and `lookyLooky` switches, which also appear in `Settings.bundle/Root.plist`). `lookyLooky` (default `true`) selects the Looky Looky game mode: `GamePresenter` copies it to `Model.lookyLooky` at the start of a game, and the model applies the extra rules. So far there is one, Extra Life: the first winning prial a player plays earns them a life and nobody loses one that round; that player's later prials work as usual (`School.awardExtraLife()`, reported through `roundEnded(losingPlayers:extraLife:)` with no losers). Lives can exceed 3. Bullet Proof: a player holding a trotter or a prial does not lose a life to a winning prial (`School.determineLosingHands(bulletProof:)`), so a round can end with no losers. Looky Looky also adds the two jokers to the pack: `Model.setUpGame` sets `Deck.hasJokers`, and `Deck.max` is the full pack size (54 with jokers, otherwise 52). The jokers are `PlayingCard.goodJoker` / `.badJoker` (suit `.joker`, ranks `.goodJoker` / `.badJoker`, images `JokerGood` / `JokerBad` plus marked backs `BackJokerGood` / `BackJokerBad`); use `Suit.standard` / `Rank.standard`, not `allCases`, for the 52 ordinary cards. Looky Looky also makes deuces wild, by suit only: a two can be the two of any suit (`HandRules.deucesWild`, a static that `Model.setUpGame` sets from `lookyLooky`, so tests that turn it on must turn it off again). The good joker is fully wild. `PlayingCard.playWildCards` plays the good joker and any wild twos as whichever cards score best (the joker never as a card already in the hand, but two wild twos may be the same two, so 2-2-x is a flush), and both `HandResolver` and `PossibleHandResolver` do this in `init`, so their `hand` holds the stand-in card rather than the joker (`HandGenerator` and the AIs get it through the resolvers; `OneDownAI` also avoids throwing the good joker away). The bad joker is a dud with no rank or suit: it does not count towards the hand, so it scores as the lowest card and never makes a pair, flush, run or prial (the other two cards can still be a pair). In tests the jokers unflatten from `GJ` and `BJ`. `Stats` turns those into win rate and rank title. `Settings.bundle` provides the iOS Settings app pages. The same two switches can be set in the app: the GAME button on the start screen opens `SettingsNode` (game Deadwood / Looky Looky, deck plain / marked), which saves each choice straightaway and has the start screen's cards reload their backs (`CardSpriteNode.reloadBack()`).

## Web version (`web/`)

A port of the game to plain JavaScript (ES modules, no framework, no build step) for the browser, to be hosted on itch.io. So far the model and the presenter: `web/js/model/` mirrors `CrazyBrag/model/` file for file (`model.js`, `school.js`, `oneDownAI.js`, `handResolver.js`, …), with the tests in `web/tests/` ported from `CrazyBragTests`. `web/js/presenter/` holds `gamePresenter.js` (GamePresenter, and the list of methods a game view must implement), `playStates.js` (all the `*State.swift` classes), `startPresenter.js` and `layout.js` (`IPadLayout`, `IPhoneLayout`, `StartLayout`, `Layer`); `web/js/settings.js` is `Settings` on the browser's local storage. `web/js/view/` is the canvas view: `stage.js` (a small stand-in for SpriteKit: nodes drawn by z, `animate()` tweens, pointer presses; no DOM, so it is unit tested), `nodes.js` (cards, labels, buttons, mats, particles, panels), `gameScene.js` (the table, the `GameView` the presenter talks to), `startScene.js` (the title screen, the `StartView`), `panels.js` (the rules and game settings panels; the rules text in `rules.js` was copied from `InformationNode.swift` and must be kept the same by hand), `assets.js`, `audio.js` (Web Audio; nothing plays until the player first clicks, a browser rule, so the title music starts then) and `app.js` (canvas, frame loop, fading between the two scenes, scaling the layout to fit the window; a window wider than 1.7:1 gets the iPhone layout, otherwise the iPad one). `web/index.html` loads `js/main.js`.

```sh
cd web && npm test          # node --test, needs Node 20 or later, no packages to install
cd web && npm run tournament   # action takers against non-takers, as OneDownAITests.tournament()
cd web && npm run serve     # then open http://localhost:8765/ (ES modules do not load from file://)
sh tools/web/build.sh       # rebuild web/assets from Assets.xcassets and CrazyBrag/sounds (ImageMagick with WebP, afconvert)
sh tools/web/package.sh     # run the tests, then zip index.html, js and assets for itch.io: tools/web/out/crazybrag-web-<version>.zip
```

- `web/assets/` is generated by `tools/web/build.sh` but is committed, so that `web/` can be served or zipped as it is: card images as half size WebP, the background, the action icons, the font, and the sounds (the long ones as AAC). Rerun the script after changing an image or sound of the iOS game.
- For testing, options go in the address: `index.html?scene=game&autoplay=1&speed=25&layout=phone` (skip the start screen, the human seat plays itself, the game runs faster, force the `phone` or `pad` layout). `window.crazyBrag` is the `App`; `crazyBrag.scene.presenter` and `crazyBrag.error` are useful from the console.

- There is one `PlayingCard` object per card (`PlayingCard.of(suit, rank)`, `PlayingCard.unflatten("kh")`), so cards are compared with `===`. Suits, ranks and hand types are numbers (`Suit.hearts`, `Rank.king`, `BragHandTypes.prial`), turns and actions are small frozen objects made by `Turn.swap/all`, `ActionChoice`, `TurnActionResult` in `defines.js`.
- `maxBy` / `minBy` in `defines.js` keep the first of equal elements, as Swift's `max(by:)` / `min(by:)` do; the computer player's choices depend on that.
- Layout positions are the same numbers as the iOS layouts, so the origin is the bottom left and y goes up; the view is to flip them for the canvas. The table layout also decides the number of computer players (`numberOfAIPlayers`).
- The presenter has no tests in the iOS game; here `web/tests/presenter.test.js` drives it with `FakeView` (`web/tests/fakeView.js`), which records every call, and a clock the test moves on. `presenter.autoPlayEnabled` (the web's `DEBUG_AUTO_PLAY`) makes the human seat play random moves and press continue.
- The game listener is any object with some of the `GameListener` methods; the model sets its next state before calling the listener.
- **Keep the two models the same.** `testPortParity` (in `OneDownAITests.swift`) and `web/tests/parity.test.js` work out the same two sums, over the score of every possible hand and over the computer player's actions and moves in 20,000 made up deals, and each checks them against the same constants. A change to the rules or to `OneDownAI` must be made in both models, then both constants updated to the new (equal) values.

## Debug aids

- `DEBUG_AUTO_PLAY` in `view/GameViewController.swift` (DEBUG builds only): when `true`, the human seat plays random moves so a game runs unattended.
- FPS/node count overlays are on in DEBUG builds only.
- `DebugRemote` (DEBUG builds only, in `view/GameViewController.swift`) lets you drive the game in a simulator, since `simctl` cannot send touches. Write one command per line to `remote.txt` in the app's Documents folder (`xcrun simctl get_app_container <device> com.mpdbailey.crazybrag data`); the scenes poll for it and delete it. Commands: `deal`, `tap 10H` (card image name), `continue` (only acts while the Continue button is showing), `close` (stats dialog), `quit`, and `action looky` / `action stash` / `action change` (the Looky Looky buttons; follow `action change` with a `tap` on a middle card). On the start screen: `help`, then `help deadwood` or `help looky`, `help next`, `help previous`, `help close` for the rules pages, and `settings`, then `settings deadwood` / `settings looky looky` / `settings plain` / `settings marked`, `settings close` for the settings panel. Use `xcrun simctl io <device> screenshot` to see the result.

## Tests

`CrazyBragTests/Hands.swift` holds shared named hand fixtures (`PrialOfAces`, etc.) used across the test classes; reuse or extend these rather than building hands inline.
