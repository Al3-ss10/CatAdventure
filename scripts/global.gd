extends Node

var vita = 3
var vitaPrev = 3
var money = 200
var MoneteCorrenti = 0
var gomitolo = false
var direction = 1
var tempo2 = 0
var box = false
var flag = false
var magnete = false
var ListaPowerUp: Dictionary = {
	'polpetta':10,
	'scatola':  4,
	'gomitolo': 1,
	'magnete':1,
}

var ItemDB: Dictionary = {
	"polpetta": {
		"id":       "polpetta",
		"name":     "Polpetta",
		"desc":     "Restores 1 life.",
		"icon":     "res://assets/sprites/polpetta icona.png",
		"rarity":   "common",
		"type":     "consumable",
		"stat":     "+1 HP",
		"price":    1,
		"equipped": false,
	},
	"gomitolo": {
		"id":       "gomitolo",
		"name":     "Gomitolo",
		"desc":     "Throwable ball of yarn that defeats enemies.",
		"icon":     "res://assets/sprites/gomitolo.png",
		"rarity":   "uncommon",
		"type":     "weapon",
		"stat":     "+DMG",
		"price":    2,
		"equipped": false,
	},
	"scatola": {
		"id":       "scatola",
		"name":     "Scatola",
		"desc":     "Floating cardboard box.",
		"icon":     "res://assets/sprites/box.png",
		"rarity":   "rare",
		"type":     "armor",
		"stat":     "+DEF",
		"price":    5,
		"equipped": false,
	},
	"magnete": {
		"id":       "magnete",
		"name":     "magnete",
		"desc":     "attracts coins ",
		"icon":     "res://assets/sprites/Magnete.png",
		"rarity":   "rare",
		"type":     "accessory",
		"stat":     "+DEF",
		"price":    5,
		"equipped": false,
	},
}
