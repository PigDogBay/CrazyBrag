// The pages of the rules, the same text as CrazyBrag/view/InformationNode.swift

/** The standard game */
export const deadwoodPages = [
    'Each player has 3 lives and takes turns\nto swap cards with the middle 3 cards.\n\nAt the end of the round the player with\nthe lowest scoring hand loses a life.',
    'If a player loses all their lives,\nthey are out of the game.\n\nPlay continues until there\nis only one player left.',
    'On your turn you must swap\n1 or 3 cards with the middle\n\nTouch a card in your hand to select it\nthen touch a middle card to swap',
    'To swap all three cards\nTouch all 3 cards in your hand\n\nThe first card selected will be\nplaced face down in the middle',
    'HANDS: HIGH\nThe highest card in your hand\nA♣️J♦️2❤️ - This is Ace high\n\n5♦️3❤️2♣️ is the lowest possible hand',
    'PAIR\nTwo cards with the same rank\nJ♦️J♠️9❤️ - Pair of Jacks\n\nAces are high, 2\'s lowest',
    'FLUSH\nAll cards are the same suit\nK❤️9❤️8❤️ - King Flush\n\nIf two king flushes are losing,\nthe next card will be compared.',
    'RUN\nSequential Ranks\n7♦️8♠️9♣️ - Seven, eight, nine\n\nA♠️2♣️3♦️ is the highest run\nThen QKA, JQK, TJQ, 9TJ...234',
    'TROTTER\nRun and all the same suit\nJ♦️Q♦️K♦️ - Jack Queen King Trotter\n\nCards can be in any order',
    'PRIAL\nAll cards are the same rank\nQ♠️Q❤️Q♦️ - Prial of Queens\n\n333\'s are the highest prial\nThen AAA, KKK...222\nAll lesser hands will lose a life!',
];

/** The extra rules of the Looky Looky game */
export const lookyLookyPages = [
    'Looky Looky is Deadwood\nwith a few house rules.\n\nEverything in the Deadwood rules\nstill applies, so read those first.',
    'EXTRA LIFE\nYour first winning prial earns you\nan extra life and nobody loses a life.\n\nThe grey heart is the life to be won.\nAfter that your prials work as usual.',
    'BULLET PROOF\nWhen a prial wins the round,\na player holding a trotter\nor a lesser prial is safe\nand keeps their life.',
    'JOKERS\nWild Bill is wild, he plays as any\ncard that is not already in your hand.\n\nCalamity Jane is a dud,\nshe counts for nothing.',
    'DEUCES ARE WILD\nA 2 can be any suit,\nbut it is always a 2.\n\n2♦️K♠️9♠️ - King Flush\n2❤️3♠️4♠️ - 2-3-4 Trotter',
    'ACTIONS\nBefore making your move you may take\nup to 2 of the 3 actions,\nusing the buttons next to your hand.\n\nEach action only once a turn.',
    'LOOKY LOOKY\nPeek at the face down card\nin the middle.\n\nOnly you get to see it.',
    'STASH HAND\nThrow in all 3 of your cards\nand get 3 new ones.\n\nCHANGE A CARD\nPick a middle card to be\nreplaced with a new one.',
];
