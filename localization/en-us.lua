local specflush = SpectrumAPI.configuration.misc.specflush_over_spectrum_flush and "Specflush" or "Flush Spectrum"

return {
    misc = {
        poker_hands = {
			["spa_Spectrum"] = "Spectrum",
            ["spa_Straight_Spectrum"] = "Straight Spectrum",
            ["spa_Royal_Spectrum"] = "Royal Spectrum",
            ["spa_Spectrum_House"] = "Spectrum House",
            ["spa_Spectrum_Five"] = "Spectrum Five",

            ["spa_Flush_Spectrum"] = specflush,
            ["spa_Straight_Flush_Spectrum"] = "Straight "..specflush,
            ["spa_Royal_Flush_Spectrum"] = "Royal "..specflush,
            ["spa_Flush_Spectrum_House"] = specflush.." House",
            ["spa_Flush_Spectrum_Five"] = specflush.." Five",
		},
		poker_hand_descriptions = {
            ["spa_Spectrum"] = {
                "5 cards with different suits"
            },
            ["spa_Straight_Spectrum"] = {
                "5 cards in a row (consecutive ranks)",
                "each with a different suit"
            },
            ["spa_Spectrum_House"] = {
                "A Three of a Kind and a Pair",
                "with each card having a different suit"
            },
            ["spa_Spectrum_Five"] = {
                "5 cards with the same rank",
                "each with a different suit"
            },
            
            ["spa_Flush_Spectrum"] = {
                "A hand containing both",
                "a Spectrum and a Flush"
            },
            ["spa_Straight_Flush_Spectrum"] = {
                "A hand containing a Straight",
                "a Spectrum, and a Flush"
            },
            ["spa_Flush_Spectrum_House"] = {
                "A hand containing a Full House",
                "a Spectrum, and a Flush"
            },
            ["spa_Flush_Spectrum_Five"] = {
                "A hand containing Five of a Kind",
                "a Spectrum, and a Flush"
            },
        }
    }
}