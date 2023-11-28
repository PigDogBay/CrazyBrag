//
//  School.swift
//  CardGames
//
//  Created by Mark Bailey on 26/09/2022.
//

import Foundation

class School {
    var players = [Player]()
    var dealer : Player? = nil
    let humanAI = HumanAI()
    
    lazy var playerBomber : Player = {
        let ai = ChancerAI()
        let player = Player(name: "Bomber", ai: ai)
        ai.player = player
        return player
    }()
    lazy var playerChris : Player = {
        let ai = ChancerAI()
        let player = Player(name: "Chris", ai: ai)
        ai.player = player
        return player
    }()
    lazy var playerLeon : Player = {
        let ai = OneDownAI()
        let player = Player(name: "Leon", ai: ai)
        ai.player = player
        return player
    }()
    lazy var playerHowie : Player = {
        let ai = ChancerAI()
        let player = Player(name: "Howie", ai: ai)
        ai.player = player
        return player
    }()
    //Human Player
    lazy var playerHuman : Player = {
        let ai = self.humanAI
        let player = Player(name: "You", ai: ai)
        ai.player = player
        return player
    }()
    lazy var playerGeordie : Player = {
        let ai = OneDownAI()
        let player = Player(name: "Geordie", ai: ai)
        ai.player = player
        return player
    }()

    var getAllPlayers : [Player] {
        [playerChris, playerHowie, playerLeon, playerBomber, playerGeordie]
    }
        
    func setUpPlayers(){
        players.removeAll()
        players.append(contentsOf: getAllPlayers)
        players.shuffle()
        //Human player if seat position 0
        players.insert(playerHuman, at: 0)
        //Set up lives and seat positions
        var seat = 0
        players.forEach{
            $0.lives = 3
            $0.seat = seat
            seat = seat + 1
        }
        dealer = players.randomElement()
    }

    ///The next player is the seat after the current player (the player's left / clockwise)
    ///If no seats left, start back round at the lowest seat, like a circular buffer
    func nextPlayer(current : Player) -> Player? {
        let next = players
            .filter{$0.seat > current.seat}
            .min(by: {$0.seat < $1.seat})
        if let n = next {
            return n
        }
        //Start back at min seat pos
        return players
            .min(by: {$0.seat < $1.seat})
    }
    
    func sortPlayersInDealOrder() -> [Player] {
        let dealerSeat = dealer?.seat ?? 0
        let after = players
            .filter{$0.seat>dealerSeat}
            .sorted(by: {$0.seat < $1.seat})
        let before = players
            .filter{$0.seat<=dealerSeat}
            .sorted(by: {$0.seat < $1.seat})

        return after + before
    }
    
    func nextDealer(){
        if let current = dealer {
            if let next = nextPlayer(current: current){
                dealer = next
            }
        }
    }
    
    func getPlayer(name : String) -> Player?{
        return players.first(where: {$0.name == name})
    }
    
    func stashCards(deck : Deck) throws {
        try players.forEach{
            try deck.receive(cards: $0.hand.stash())
        }
    }
    
    func showAllHands(){
        players.forEach{
            $0.hand.show()
        }
    }
    func resolveHands(){
        players.forEach{
            $0.resolveHand()
        }
    }
    
    func isPrialOut() -> Bool{
        return !players.filter{$0.score.type == .prial}
            .isEmpty
    }
    
    ///Needed to find player with largest Prial
    func highestScoringPlayer() -> Player? {
        return players.max(by: {$0.score < $1.score})
    }
    
    func determineLosingHands() -> [Player]? {
        if isPrialOut(){
            let topPlayer = highestScoringPlayer()
            //"Prial out, everyone (else) out!" cries the top player
            return players.filter{$0.name != topPlayer?.name}
            
        }
        return Dictionary(grouping: players, by:  {$0.score.score})
            .min(by: {$0.key < $1.key})
            .map{$0.value}
    }
    
    func playersWithNoLivesLeft() -> [Player]{
        players.filter{$0.lives == 0}
    }
    
    func removePlayersWithNoLivesLeft() {
        let remaining = players.filter{$0.lives>0}
        players.removeAll()
        players.append(contentsOf: remaining)
    }
    
    func areAllPlayersOut() -> Bool {
        players.filter{$0.lives != 0}.count == 0
    }
    
    ///If all players had the same hand and so are all out
    ///then no one has won the game, so this round needs
    ///to be replayed, give the remaining players 1 life back.
    func reinstatePlayers() {
        players.forEach{$0.lives = 1}
    }
    
}
